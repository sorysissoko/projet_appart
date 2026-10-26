import 'dart:async';

import 'package:flutter/material.dart';
import 'package:service/session_timeout_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';
import 'error_handler.dart';
import 'security_service.dart';
import 'service_locator.dart';

class AuthServiceWrapper extends ChangeNotifier {

  // SINGLETON
  static final AuthServiceWrapper _instance =
  AuthServiceWrapper._internal();

  factory AuthServiceWrapper() => _instance;

  AuthServiceWrapper._internal() {
    _init();
  }


  // SERVICES
  AuthService get _authService => ServiceLocator.auth;

  SupabaseClient get _supabase => Supabase.instance.client;

  StreamSubscription<AuthState>? _authSubscription;


  // ÉTAT
  bool _initialized = false;
  bool _disposed = false;
  bool _isLoading = false;

  User? _currentUser;
  String? _currentRole;
  String? _errorMessage;


  // GETTERS
  bool get initialized => _initialized;

  bool get isLoading => _isLoading;

  User? get currentUser => _currentUser;

  String? get currentRole => _currentRole;

  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentUser != null;


  // RÔLES
  bool get isAdminUser {
    return SecurityService.isAdmin(_currentRole);
  }

  bool get isSuperAdmin {
    return SecurityService.isSuperAdmin(_currentRole);
  }

  bool get isOwner {
    return SecurityService.isProprietaire(_currentRole);
  }

  bool get isTenant {
    return SecurityService.isLocataire(_currentRole);
  }


  // ACCÈS AUX ESPACES
  bool get canAccessOwner {
    return SecurityService.canAccessOwner(_currentRole);
  }

  bool get canAccessTenant {
    return SecurityService.canAccessTenant(_currentRole);
  }

  bool get canAccessAdmin {
    return SecurityService.canAccessAdminApp(_currentRole);
  }


  // INITIALISATION
  void _init() {
    if (_initialized || _disposed) {
      return;
    }

    _initialized = true;

    try {

      // SESSION EXISTANTE
      _currentUser = _supabase.auth.currentUser;

      if (_currentUser != null) {
        unawaited(_loadCurrentRole());
      }

      // ÉCOUTE DES CHANGEMENTS AUTH SUPABASE
      _authSubscription =
          _supabase.auth.onAuthStateChange.listen(
            _handleAuthStateChange,
            onError: (Object error, StackTrace stackTrace) {
              ErrorHandler.log(
                error,
                context: 'Supabase Auth Stream',
              );
            },
          );
    } catch (e) {
      ErrorHandler.log(
        e,
        context: 'Initialisation AuthServiceWrapper',
      );
    }
  }


  // AUTH STATE CHANGE
  Future<void> _handleAuthStateChange(
      AuthState state,
      ) async {
    if (_disposed) {
      return;
    }

    try {
      final sessionUser = state.session?.user;

      // UTILISATEUR DÉCONNECTÉ
      if (sessionUser == null) {
        _currentUser = null;
        _currentRole = null;
        _errorMessage = null;

        _safeNotify();

        if (state.event == AuthChangeEvent.signedOut) {
          _handleSignedOut();
        }

        return;
      }

      // UTILISATEUR CONNECTÉ
      _currentUser = sessionUser;
      _errorMessage = null;

      // CHARGER LE RÔLE
      await _loadCurrentRole();

      if (_disposed) {
        return;
      }

      // SI LE RÔLE EST INVALIDE
      if (_currentRole == null) {
        await _authService.signOut();

        _currentUser = null;
        _currentRole = null;

        _safeNotify();

        return;
      }

      _safeNotify();

      // SIGNED IN
      if (state.event == AuthChangeEvent.signedIn) {
        await SessionTimeoutService().resetAfterLogin();

        if (_disposed) {
          return;
        }

        _handleSignedIn(sessionUser);
      }

      // TOKEN RENOUVELÉ
      if (state.event == AuthChangeEvent.tokenRefreshed) {
        debugPrint(
          'Token Supabase renouvelé.',
        );
      }

      // UTILISATEUR MIS À JOUR
      if (state.event == AuthChangeEvent.userUpdated) {
        debugPrint(
          'Utilisateur Supabase mis à jour.',
        );
      }

      // PASSWORD RECOVERY
      if (state.event == AuthChangeEvent.passwordRecovery) {
        debugPrint(
          'Récupération du mot de passe.',
        );
      }
    } catch (e) {
      ErrorHandler.log(
        e,
        context: 'AuthStateChange',
      );
    }
  }

  // CHARGER LE RÔLE COURANT
  Future<void> _loadCurrentRole() async {
    final user = _currentUser;

    if (user == null || _disposed) {
      _currentRole = null;
      return;
    }

    try {
      final role = await _authService.getCurrentUserRole();

      if (_disposed) {
        return;
      }

      // VÉRIFIER QUE L'UTILISATEUR EST TOUJOURS LE MÊME
      final currentSupabaseUser =
          _supabase.auth.currentUser;

      if (currentSupabaseUser == null ||
          currentSupabaseUser.id != user.id) {
        _currentRole = null;
        return;
      }

      // VALIDER LE RÔLE
      if (role != null &&
          SecurityService.isValidRole(role)) {
        _currentRole =
            SecurityService.normalizeRole(role);

        debugPrint(
          'Rôle utilisateur : $_currentRole',
        );
      } else {
        _currentRole = null;

        debugPrint(
          'Rôle utilisateur invalide ou absent : $role',
        );
      }
    } catch (e) {
      _currentRole = null;

      ErrorHandler.log(
        e,
        context: 'Chargement rôle utilisateur',
      );
    }
  }

  // GET ROLE
  Future<String?> getUserRole() async {
    if (_disposed) {
      return null;
    }

    if (_currentUser == null) {
      return null;
    }

    if (_currentRole != null) {
      return _currentRole;
    }

    await _loadCurrentRole();

    return _currentRole;
  }

  // CHECK ADMIN
  Future<bool> isAdmin() async {
    final role = await getUserRole();

    return SecurityService.isAdmin(role);
  }

  // CHECK SUPER ADMIN
  Future<bool> isSuperAdminUser() async {
    final role = await getUserRole();

    return SecurityService.isSuperAdmin(role);
  }

  // CHECK PROPRIÉTAIRE
  Future<bool> isProprietaire() async {
    final role = await getUserRole();

    return SecurityService.isProprietaire(role);
  }

  // CHECK LOCATAIRE
  Future<bool> isLocataire() async {
    final role = await getUserRole();

    return SecurityService.isLocataire(role);
  }

  // ACCÈS ESPACE PROPRIÉTAIRE
  Future<bool> canAccessOwnerSpace() async {
    final role = await getUserRole();

    return SecurityService.canAccessOwner(role);
  }

  // ACCÈS ESPACE LOCATAIRE
  Future<bool> canAccessTenantSpace() async {
    final role = await getUserRole();

    return SecurityService.canAccessTenant(role);
  }

  // ACCÈS APPLICATION ADMIN
  Future<bool> canAccessAdminApp() async {
    final role = await getUserRole();

    return SecurityService.canAccessAdminApp(role);
  }

  // ACCÈS APPLICATION PROPRIÉTAIRE
  Future<bool> canAccessOwnerApp() async {
    final role = await getUserRole();

    return SecurityService.canAccessOwnerApp(role);
  }

  // ACCÈS APPLICATION LOCATAIRE
  Future<bool> canAccessTenantApp() async {
    final role = await getUserRole();

    return SecurityService.canAccessTenantApp(role);
  }


  // ============================================================
  // 🔴 NOUVEAU : VÉRIFICATION CERTIFICATION
  // ============================================================

  /// Vérifie si l'utilisateur actuellement connecté est certifié.
  ///
  /// Retourne `true` si `est_certifie = true` en base, `false` sinon.
  /// Retourne `false` en cas d'erreur pour éviter de bloquer l'UI.
  Future<bool> isCertified() async {
    if (_disposed) {
      return false;
    }

    final user = _currentUser;
    if (user == null) {
      return false;
    }

    try {
      final profile = await getProfile();

      if (_disposed) return false;

      return profile?['est_certifie'] == true;
    } catch (e) {
      ErrorHandler.log(
        e,
        context: 'isCertified',
      );

      return false;
    }
  }


  // CONNEXION
  Future<bool> signIn(
      String email,
      String password,
      ) async {
    if (_disposed) {
      return false;
    }

    if (_isLoading) {
      return false;
    }

    _startLoading();

    try {
      final cleanEmail = email.trim();
      final cleanPassword = password;

      // VALIDATION EMAIL
      if (!SecurityService.isValidEmail(cleanEmail)) {
        _errorMessage =
        'Adresse email invalide.';

        return false;
      }

      // VALIDATION PASSWORD
      if (cleanPassword.isEmpty) {
        _errorMessage =
        'Mot de passe requis.';

        return false;
      }

      // CONNEXION SUPABASE
      final user =
      await _authService.loginWithMailPassword(
        cleanEmail,
        cleanPassword,
      );

      if (_disposed) {
        return false;
      }

      if (user == null) {
        _errorMessage =
        'Email ou mot de passe incorrect.';

        return false;
      }

      _currentUser = user;

      // CHARGER LE RÔLE
      await _loadCurrentRole();

      if (_disposed) {
        return false;
      }

      // RÔLE INVALIDE
      if (_currentRole == null) {
        await _authService.signOut();

        _currentUser = null;
        _currentRole = null;

        _errorMessage =
        'Le rôle de ce compte est invalide.';

        _safeNotify();

        return false;
      }

      // DÉMARRER LE TIMEOUT
      await SessionTimeoutService().resetAfterLogin();

      if (_disposed) {
        return false;
      }

      // NETTOYER ERREUR
      _errorMessage = null;

      // LOGS

      debugPrint(
        'CONNEXION RÉUSSIE',
      );

      debugPrint(
        'Utilisateur : ${_currentUser?.email}',
      );

      debugPrint(
        '🔐 Rôle : $_currentRole',
      );

      debugPrint(
        'Admin : $canAccessAdmin',
      );

      debugPrint(
        'Propriétaire : $canAccessOwner',
      );

      debugPrint(
        'Locataire : $canAccessTenant',
      );

      debugPrint(
        'Timeout inactivité : 15 minutes',
      );


      _safeNotify();

      return true;
    } catch (e) {
      if (!_disposed) {
        _errorMessage = ErrorHandler.clean(e);

        ErrorHandler.log(
          e,
          context: 'Connexion',
        );
      }

      return false;
    } finally {
      _stopLoading();
    }
  }

  // INSCRIPTION LOCATAIRE
  Future<bool> signUpLocataire({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
    String? adresse,
    String? urgencephone,
  }) async {
    if (_disposed || _isLoading) {
      return false;
    }

    _startLoading();

    try {
      final validation =
      SecurityService.validatePasswordForRole(
        password: password,
        role: SecurityService.roleLocataire,
      );

      if (!validation.isValid) {
        _errorMessage = validation.message;
        return false;
      }

      final cleanEmail = email.trim();

      if (!SecurityService.isValidEmail(cleanEmail)) {
        _errorMessage =
        'Adresse email invalide.';
        return false;
      }

      final cleanNom = nom.trim();

      if (!SecurityService.isValidName(cleanNom)) {
        _errorMessage =
        'Nom invalide.';
        return false;
      }

      final cleanPrenom = prenom.trim();

      if (!SecurityService.isValidName(cleanPrenom)) {
        _errorMessage =
        'Prénom invalide.';
        return false;
      }

      final cleanTelephone = telephone.trim();

      if (!SecurityService.isValidPhone(cleanTelephone)) {
        _errorMessage =
        'Numéro de téléphone invalide.';
        return false;
      }

      final user =
      await _authService.signUpWithEmailPassword(
        email: cleanEmail,
        password: password,
        nom: cleanNom,
        prenom: cleanPrenom,
        telephone: cleanTelephone,
        adresse: adresse?.trim(),
        urgencephone: urgencephone?.trim(),
        role: SecurityService.roleLocataire,
      );

      if (_disposed) {
        return false;
      }

      if (user == null) {
        _errorMessage =
        'Impossible de créer le compte.';
        return false;
      }

      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.clean(e);

      ErrorHandler.log(
        e,
        context: 'Inscription locataire',
      );

      return false;
    } finally {
      _stopLoading();
    }
  }

  // INSCRIPTION PROPRIÉTAIRE
  Future<bool> signUpOwner({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
    String? adresse,
    String? urgencephone,
    String? ville,
    String? dateNaissance,
  }) async {
    if (_disposed || _isLoading) {
      return false;
    }

    _startLoading();

    try {
      final validation =
      SecurityService.validatePasswordForRole(
        password: password,
        role: SecurityService.roleProprietaire,
      );

      if (!validation.isValid) {
        _errorMessage = validation.message;
        return false;
      }

      final cleanEmail = email.trim();

      if (!SecurityService.isValidEmail(cleanEmail)) {
        _errorMessage =
        'Adresse email invalide.';
        return false;
      }

      final cleanNom = nom.trim();

      if (!SecurityService.isValidName(cleanNom)) {
        _errorMessage =
        'Nom invalide.';
        return false;
      }

      final cleanPrenom = prenom.trim();

      if (!SecurityService.isValidName(cleanPrenom)) {
        _errorMessage =
        'Prénom invalide.';
        return false;
      }

      final cleanTelephone = telephone.trim();

      if (!SecurityService.isValidPhone(cleanTelephone)) {
        _errorMessage =
        'Numéro de téléphone invalide.';
        return false;
      }

      final user =
      await _authService.signUpWithEmailPassword(
        email: cleanEmail,
        password: password,
        nom: cleanNom,
        prenom: cleanPrenom,
        telephone: cleanTelephone,
        adresse: adresse?.trim(),
        urgencephone: urgencephone?.trim(),
        ville: ville?.trim(),
        dateNaissance: dateNaissance,
        role: SecurityService.roleProprietaire,
      );

      if (_disposed) {
        return false;
      }

      if (user == null) {
        _errorMessage =
        'Impossible de créer le compte.';
        return false;
      }

      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.clean(e);

      ErrorHandler.log(
        e,
        context: 'Inscription propriétaire',
      );

      return false;
    } finally {
      _stopLoading();
    }
  }

  // CRÉATION ADMIN
  Future<bool> createAdminAccount({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
  }) async {
    if (_disposed || _isLoading) {
      return false;
    }

    _startLoading();

    try {

      // SEUL ADMIN

      if (!isAdminUser) {
        _errorMessage =
        'Accès réservé aux administrateurs.';

        return false;
      }


      // PASSWORD
      final validation =
      SecurityService.validatePasswordForRole(
        password: password,
        role: SecurityService.roleAdmin,
      );

      if (!validation.isValid) {
        _errorMessage = validation.message;
        return false;
      }


      // EMAIL
      final cleanEmail = email.trim();

      if (!SecurityService.isValidEmail(cleanEmail)) {
        _errorMessage =
        'Adresse email invalide.';
        return false;
      }


      // NOM
      final cleanNom = nom.trim();

      if (!SecurityService.isValidName(cleanNom)) {
        _errorMessage =
        'Nom invalide.';
        return false;
      }


      // PRÉNOM
      final cleanPrenom = prenom.trim();

      if (!SecurityService.isValidName(cleanPrenom)) {
        _errorMessage =
        'Prénom invalide.';
        return false;
      }


      // TÉLÉPHONE
      final cleanTelephone = telephone.trim();

      if (!SecurityService.isValidPhone(cleanTelephone)) {
        _errorMessage =
        'Numéro de téléphone invalide.';
        return false;
      }


      // SÉCURITÉ
      _errorMessage =
      'La création d’un administrateur doit être effectuée '
          'par une opération serveur sécurisée.';

      return false;
    } catch (e) {
      _errorMessage = ErrorHandler.clean(e);

      ErrorHandler.log(
        e,
        context: 'Création compte administrateur',
      );

      return false;
    } finally {
      _stopLoading();
    }
  }


  // DÉCONNEXION
  Future<bool> signOut() async {
    if (_disposed || _isLoading) {
      return false;
    }

    _startLoading();

    try {
      await _authService.signOut();

      _currentUser = null;
      _currentRole = null;
      _errorMessage = null;

      _safeNotify();

      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.clean(e);

      ErrorHandler.log(
        e,
        context: 'Déconnexion',
      );

      return false;
    } finally {
      _stopLoading();
    }
  }


  // RESET PASSWORD
  Future<bool> resetPassword(
      String email,
      ) async {
    if (_disposed || _isLoading) {
      return false;
    }

    _startLoading();

    try {
      final cleanEmail = email.trim();

      if (!SecurityService.isValidEmail(cleanEmail)) {
        _errorMessage =
        'Adresse email invalide.';
        return false;
      }

      await _authService.resetPassword(
        email: cleanEmail,
      );

      if (_disposed) {
        return false;
      }

      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.clean(e);

      ErrorHandler.log(
        e,
        context: 'Reset password',
      );

      return false;
    } finally {
      _stopLoading();
    }
  }


  // PROFIL
  Future<Map<String, dynamic>?> getProfile() async {
    if (_disposed) {
      return null;
    }

    try {
      return await _authService.getProfile();
    } catch (e) {
      ErrorHandler.log(
        e,
        context: 'getProfile',
      );

      return null;
    }
  }

  // MODIFIER PROFIL
  Future<bool> updateProfile({
    required String nom,
    required String prenom,
    String? telephone,
    String? adresse,
  }) async {
    if (_disposed || _isLoading) {
      return false;
    }

    _startLoading();

    try {
      final cleanNom = nom.trim();
      final cleanPrenom = prenom.trim();
      final cleanTelephone = telephone?.trim();
      final cleanAdresse = adresse?.trim();

      if (!SecurityService.isValidName(cleanNom)) {
        _errorMessage =
        'Nom invalide.';
        return false;
      }

      if (!SecurityService.isValidName(cleanPrenom)) {
        _errorMessage =
        'Prénom invalide.';
        return false;
      }

      if (cleanTelephone != null &&
          cleanTelephone.isNotEmpty &&
          !SecurityService.isValidPhone(cleanTelephone)) {
        _errorMessage =
        'Numéro de téléphone invalide.';
        return false;
      }

      if (!SecurityService.isValidAddress(cleanAdresse)) {
        _errorMessage =
        'Adresse invalide.';
        return false;
      }

      await _authService.updateProfile(
        nom: cleanNom,
        prenom: cleanPrenom,
        telephone: cleanTelephone,
        adresse: cleanAdresse,
      );

      if (_disposed) {
        return false;
      }

      _currentUser = _supabase.auth.currentUser;
      _errorMessage = null;

      _safeNotify();

      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.clean(e);

      ErrorHandler.log(
        e,
        context: 'updateProfile',
      );

      return false;
    } finally {
      _stopLoading();
    }
  }


  // TÉLÉPHONE D'URGENCE
  Future<bool> updatePhoneUrgence(
      String phone,
      ) async {
    if (_disposed || _isLoading) {
      return false;
    }

    _startLoading();

    try {
      final cleanPhone = phone.trim();

      if (!SecurityService.isValidPhone(cleanPhone)) {
        _errorMessage =
        'Numéro de téléphone invalide.';
        return false;
      }

      await _authService.updatePhoneUrgence(
        cleanPhone,
      );

      if (_disposed) {
        return false;
      }

      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.clean(e);

      ErrorHandler.log(
        e,
        context: 'updatePhoneUrgence',
      );

      return false;
    } finally {
      _stopLoading();
    }
  }

  // MISE À JOUR ADRESSE
  Future<bool> updateAdresse(
      String adresse,
      ) async {
    if (_disposed || _isLoading) {
      return false;
    }

    _startLoading();

    try {
      final cleanAdresse = adresse.trim();

      if (!SecurityService.isValidAddress(cleanAdresse)) {
        _errorMessage =
        'Adresse invalide.';
        return false;
      }

      await _authService.updateAdresseSimple(
        cleanAdresse,
      );

      if (_disposed) {
        return false;
      }

      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.clean(e);

      ErrorHandler.log(
        e,
        context: 'updateAdresse',
      );

      return false;
    } finally {
      _stopLoading();
    }
  }


  // MISE À JOUR PASSWORD
  Future<bool> updatePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_disposed || _isLoading) {
      return false;
    }

    _startLoading();

    try {
      final role = await getUserRole();

      if (_disposed) {
        return false;
      }

      if (role == null) {
        _errorMessage =
        'Impossible de déterminer le rôle utilisateur.';

        return false;
      }

      final validation =
      SecurityService.validatePasswordForRole(
        password: newPassword,
        role: role,
      );

      if (!validation.isValid) {
        _errorMessage = validation.message;
        return false;
      }

      await _authService.updatePassword(
        email: email.trim(),
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (_disposed) {
        return false;
      }

      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.clean(e);

      ErrorHandler.log(
        e,
        context: 'updatePassword',
      );

      return false;
    } finally {
      _stopLoading();
    }
  }

  // SUPPRESSION COMPTE
  Future<bool> deleteCurrentUserAccount() async {
    if (_disposed || _isLoading) {
      return false;
    }

    _startLoading();

    try {
      await _authService.deleteCurrentUserAccount();

      if (_disposed) {
        return false;
      }

      _currentUser = null;
      _currentRole = null;
      _errorMessage = null;

      _safeNotify();

      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.clean(e);

      ErrorHandler.log(
        e,
        context: 'deleteCurrentUserAccount',
      );

      return false;
    } finally {
      _stopLoading();
    }
  }

  // VÉRIFICATION SESSION
  Future<bool> checkSession() async {
    if (_disposed) {
      return false;
    }

    final user = _supabase.auth.currentUser;

    if (user == null) {
      _currentUser = null;
      _currentRole = null;

      _safeNotify();

      return false;
    }

    try {

      // VÉRIFIER D'ABORD LE TIMEOUT D'INACTIVITÉ
      final sessionTimeout = SessionTimeoutService();

      final sessionExpired =
      await sessionTimeout.checkExpiration();

      if (sessionExpired) {
        _currentUser = null;
        _currentRole = null;

        _safeNotify();

        return false;
      }

      // RAFRAÎCHIR LA SESSION SUPABASE
      final valid =
      await _authService.refreshSessionIfNeeded();

      if (_disposed) {
        return false;
      }

      if (!valid) {
        _currentUser = null;
        _currentRole = null;

        _safeNotify();

        return false;
      }

      // RÉCUPÉRER L'UTILISATEUR
      _currentUser = _supabase.auth.currentUser;

      if (_currentUser == null) {
        _currentRole = null;

        _safeNotify();

        return false;
      }

      // RÉCUPÉRER LE RÔLE
      await _loadCurrentRole();

      if (_disposed) {
        return false;
      }

      // RÔLE INVALIDE
      if (_currentRole == null) {
        await _authService.signOut();

        _currentUser = null;
        _currentRole = null;

        _safeNotify();

        return false;
      }

      _safeNotify();

      return true;
    } catch (e) {
      ErrorHandler.log(
        e,
        context: 'checkSession',
      );

      return false;
    }
  }


  // UTILISATEUR CONNECTÉ
  void _handleSignedIn(User user) {
    if (_disposed) {
      return;
    }


    debugPrint(
      'UTILISATEUR CONNECTÉ',
    );

    debugPrint(
      'Email : ${user.email}',
    );

    debugPrint(
      'ID : ${user.id}',
    );

    debugPrint(
      'Rôle : $_currentRole',
    );

    debugPrint(
      'Accès Admin : $canAccessAdmin',
    );

    debugPrint(
      'Accès Propriétaire : $canAccessOwner',
    );

    debugPrint(
      'Accès Locataire : $canAccessTenant',
    );

  }

  // UTILISATEUR DÉCONNECTÉ
  void _handleSignedOut() {
    if (_disposed) {
      return;
    }

    _currentUser = null;
    _currentRole = null;
    _errorMessage = null;

    _safeNotify();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        if (_disposed) {
          return;
        }

        try {
          ServiceLocator.navigation.goToLogin();
        } catch (e) {
          ErrorHandler.log(
            e,
            context: 'Navigation après déconnexion',
          );
        }
      },
    );
  }

  // LOADING
  void _startLoading() {
    if (_disposed) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    _safeNotify();
  }

  void _stopLoading() {
    if (_disposed) {
      return;
    }

    _isLoading = false;

    _safeNotify();
  }


  // ERROR
  void clearError() {
    if (_disposed) {
      return;
    }

    _errorMessage = null;

    _safeNotify();
  }


  // NOTIFY SÉCURISÉ
  void _safeNotify() {
    if (_disposed) {
      return;
    }

    notifyListeners();
  }

  // DISPOSE
  @override
  void dispose() {
    if (_disposed) {
      return;
    }

    _disposed = true;

    _authSubscription?.cancel();
    _authSubscription = null;

    super.dispose();
  }
}