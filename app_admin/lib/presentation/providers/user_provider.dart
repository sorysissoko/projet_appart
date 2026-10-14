// lib/presentation/providers/user_provider.dart

import 'package:flutter/foundation.dart';

import 'package:service/backend_service.dart';
import 'package:service/service_locator.dart';

/// ============================================================
/// USER PROVIDER
/// ============================================================
///
/// Gestion de l'utilisateur connecté.
///
/// Responsabilités :
/// - charger le profil
/// - exposer les informations utilisateur
/// - vérifier les rôles
/// - modifier le profil
/// - modifier le téléphone d'urgence
/// - modifier l'adresse
/// - modifier le mot de passe
/// - supprimer le compte
/// - gérer la session
/// - gérer la déconnexion
///
class UserProvider extends ChangeNotifier {
  // ============================================================
  // SERVICE
  // ============================================================

  final BackendService _backendService = ServiceLocator.backend;

  // ============================================================
  // ÉTAT
  // ============================================================

  Map<String, dynamic>? _profile;

  bool _isLoading = false;

  bool _isLoggingOut = false;

  String? _error;

  // ============================================================
  // GETTERS
  // ============================================================

  Map<String, dynamic>? get profile => _profile;

  bool get isLoading => _isLoading;

  bool get isLoggingOut => _isLoggingOut;

  String? get error => _error;

  // ============================================================
  // AUTHENTIFICATION
  // ============================================================

  bool get isAuthenticated => _backendService.isAuthenticated;

  // ============================================================
  // UTILISATEUR
  // ============================================================

  String get email {
    return _backendService.currentUser?.email ?? '';
  }

  // ============================================================
  // INFORMATIONS
  // ============================================================

  String get nom {
    return (_profile?['nom'] ?? '').toString();
  }

  String get prenom {
    return (_profile?['prenom'] ?? '').toString();
  }

  String get telephone {
    return (_profile?['telephone'] ?? '').toString();
  }

  String get adresse {
    return (_profile?['adresse'] ?? '').toString();
  }

  String get urgencephone {
    return (_profile?['urgencephone'] ?? '').toString();
  }

  // ============================================================
  // NOM COMPLET
  // ============================================================

  String get displayName {
    final fullName = '$prenom $nom'.trim();

    if (fullName.isNotEmpty) {
      return fullName;
    }

    if (email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Utilisateur';
  }

  // ============================================================
  // INITIAL
  // ============================================================

  String get initial {
    final name = displayName.trim();

    if (name.isEmpty) {
      return 'U';
    }

    return name[0].toUpperCase();
  }

  // ============================================================
  // RÔLE BRUT
  // ============================================================

  String get rawRole {
    final role = (_profile?['role'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    if (role.isEmpty) {
      return 'utilisateur';
    }

    return role;
  }

  // ============================================================
  // RÔLE AFFICHÉ
  // ============================================================

  String get role {
    switch (rawRole) {
      case 'admin':
      case 'super_admin':
        return 'Administrateur';

      case 'proprietaire':
        return 'Propriétaire';

      case 'locataire':
        return 'Locataire';

      default:
        return 'Utilisateur';
    }
  }

  String get displayRole => role;

  // ============================================================
  // RÔLES
  // ============================================================

  bool get isAdmin {
    return rawRole == 'admin' ||
        rawRole == 'super_admin';
  }

  bool get isProprietaire {
    return rawRole == 'proprietaire';
  }

  bool get isLocataire {
    return rawRole == 'locataire';
  }

  // ============================================================
  // CHARGEMENT PROFIL
  // ============================================================

  Future<void> loadProfile() async {
    if (_isLoading) {
      return;
    }

    if (!_backendService.isAuthenticated) {
      _profile = null;
      _error = 'Utilisateur non connecté';

      notifyListeners();
      return;
    }

    _startLoading();

    try {
      final profile =
      await _backendService.getCurrentProfile();

      if (profile == null) {
        _profile = null;
        _error = 'Profil non trouvé';
      } else {
        _profile = profile;
        _error = null;
      }
    } catch (e) {
      _profile = null;
      _error = _cleanError(e);

      if (kDebugMode) {
        debugPrint(
          '❌ UserProvider.loadProfile: $e',
        );
      }
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // RAFRAÎCHIR
  // ============================================================

  Future<void> refreshProfile() async {
    if (_isLoading) {
      return;
    }

    await loadProfile();
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<bool> logout() async {
    if (_isLoggingOut) {
      return false;
    }

    _isLoggingOut = true;
    _error = null;

    notifyListeners();

    try {
      await _backendService.signOut();

      _profile = null;

      if (kDebugMode) {
        debugPrint(
          '✅ UserProvider : déconnexion réussie',
        );
      }

      return true;
    } catch (e) {
      _error = _cleanError(e);

      if (kDebugMode) {
        debugPrint(
          '❌ UserProvider.logout: $e',
        );
      }

      return false;
    } finally {
      _isLoggingOut = false;

      notifyListeners();
    }
  }

  // ============================================================
  // NETTOYER
  // ============================================================

  void clearProfile() {
    _profile = null;
    _error = null;
    _isLoggingOut = false;

    notifyListeners();
  }

  // ============================================================
  // MISE À JOUR PROFIL
  // ============================================================

  Future<bool> updateProfile({
    String? nom,
    String? prenom,
    String? telephone,
    String? adresse,
  }) async {
    if (_isLoading) {
      return false;
    }

    _startLoading();

    try {
      await _backendService.updateProfile(
        nom: nom ?? this.nom,
        prenom: prenom ?? this.prenom,
        telephone: telephone ?? this.telephone,
        adresse: adresse ?? this.adresse,
      );

      await _reloadProfile();

      return true;
    } catch (e) {
      _error = _cleanError(e);

      if (kDebugMode) {
        debugPrint(
          '❌ UserProvider.updateProfile: $e',
        );
      }

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // TÉLÉPHONE D'URGENCE
  // ============================================================

  Future<bool> updatePhoneUrgence(
      String urgencePhone,
      ) async {
    if (_isLoading) {
      return false;
    }

    _startLoading();

    try {
      await _backendService.updatePhoneUrgence(
        urgencePhone,
      );

      await _reloadProfile();

      return true;
    } catch (e) {
      _error = _cleanError(e);

      if (kDebugMode) {
        debugPrint(
          '❌ UserProvider.updatePhoneUrgence: $e',
        );
      }

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // ADRESSE
  // ============================================================

  Future<bool> updateAdresse(
      String nouvelleAdresse,
      ) async {
    if (_isLoading) {
      return false;
    }

    _startLoading();

    try {
      await _backendService.updateAdresse(
        nouvelleAdresse,
      );

      await _reloadProfile();

      return true;
    } catch (e) {
      _error = _cleanError(e);

      if (kDebugMode) {
        debugPrint(
          '❌ UserProvider.updateAdresse: $e',
        );
      }

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // CHANGEMENT MOT DE PASSE
  // ============================================================

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_isLoading) {
      return false;
    }

    if (email.isEmpty) {
      _error = 'Adresse email introuvable';

      notifyListeners();

      return false;
    }

    _startLoading();

    try {
      await _backendService.updatePassword(
        email: email,
        oldPassword: currentPassword,
        newPassword: newPassword,
      );

      return true;
    } catch (e) {
      _error = _cleanError(e);

      if (kDebugMode) {
        debugPrint(
          '❌ UserProvider.changePassword: $e',
        );
      }

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // SUPPRESSION COMPTE
  // ============================================================

  Future<bool> deleteAccount() async {
    if (_isLoading) {
      return false;
    }

    _startLoading();

    try {
      await _backendService.deleteCurrentUserAccount();

      _profile = null;

      return true;
    } catch (e) {
      _error = _cleanError(e);

      if (kDebugMode) {
        debugPrint(
          '❌ UserProvider.deleteAccount: $e',
        );
      }

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // SESSION
  // ============================================================

  Future<bool> checkSession() async {
    try {
      final result =
      await _backendService.refreshSessionIfNeeded();

      if (!result) {
        _profile = null;
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ UserProvider.checkSession: $e',
        );
      }

      return false;
    }
  }

  // ============================================================
  // PROFIL COMPLET
  // ============================================================

  Future<bool> updateFullProfile({
    required String nom,
    required String prenom,
    String? telephone,
    String? adresse,
    String? urgencephone,
  }) async {
    if (_isLoading) {
      return false;
    }

    _startLoading();

    try {
      await _backendService.updateProfile(
        nom: nom,
        prenom: prenom,
        telephone: telephone,
        adresse: adresse,
      );

      if (urgencephone != null) {
        await _backendService.updatePhoneUrgence(
          urgencephone,
        );
      }

      await _reloadProfile();

      return true;
    } catch (e) {
      _error = _cleanError(e);

      if (kDebugMode) {
        debugPrint(
          '❌ UserProvider.updateFullProfile: $e',
        );
      }

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // RECHARGER
  // ============================================================

  Future<void> _reloadProfile() async {
    final profile =
    await _backendService.getCurrentProfile();

    if (profile != null) {
      _profile = profile;
    }
  }

  // ============================================================
  // LOADING
  // ============================================================

  void _startLoading() {
    _isLoading = true;
    _error = null;

    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;

    notifyListeners();
  }

  // ============================================================
  // ERREUR
  // ============================================================

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    );
  }
}