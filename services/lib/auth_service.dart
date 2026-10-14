// lib/service/auth_service.dart

import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'error_handler.dart';
import 'security_service.dart';

class AuthService {
  AuthService();

  // SUPABASE
  SupabaseClient get _supabase {
    return Supabase.instance.client;
  }


  // UTILISATEUR COURANT
  User? get currentUser {
    return _supabase.auth.currentUser;
  }

  bool get isAuthenticated {
    return currentUser != null;
  }

  Future<Map<String, dynamic>?> getCurrentUserPaymentPhone() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    try {
      final response = await _supabase
          .from('users')
          .select('telephone')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return response;
    } catch (e) {
      print('Erreur récupération téléphone locataire : $e');
      rethrow;
    }
  }


  // RÔLE UTILISATEUR
  Future<String?> getCurrentUserRole() async {
    final user = currentUser;

    if (user == null) {
      return null;
    }


    //RÉCUPÉRATION DEPUIS PROFILES
    try {
      final profile = await _supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        final roleValue = profile['role'];

        if (roleValue != null) {
          final role = SecurityService.normalizeRole(
            roleValue.toString(),
          );

          if (SecurityService.isValidRole(role)) {
            return role;
          }
        }
      }
    } catch (e) {
      ErrorHandler.log(
        e,
        context: 'Récupération du rôle depuis profiles',
      );
    }


    //FALLBACK SUR LES MÉTADONNÉES SUPABASE
    try {
      final metadataRole = user.userMetadata?['role'];

      if (metadataRole != null) {
        final role = SecurityService.normalizeRole(
          metadataRole.toString(),
        );

        if (SecurityService.isValidRole(role)) {
          return role;
        }
      }
    } catch (e) {
      ErrorHandler.log(
        e,
        context: 'Récupération du rôle depuis userMetadata',
      );
    }


    //AUCUN RÔLE VALIDE
    return null;
  }


  // ADMIN
  Future<bool> isAdmin() async {
    final role = await getCurrentUserRole();

    return SecurityService.isAdmin(role);
  }

  Future<Map<String, dynamic>> createAdmin({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
  }) async {

    //RECUPERER LA SESSION COURANTE
    final session = _supabase.auth.currentSession;

    if (session == null) {
      throw Exception(
        'Session administrateur absente. Veuillez vous reconnecter.',
      );
    }

    final accessToken = session.accessToken;

    if (accessToken.isEmpty) {
      throw Exception(
        'Token de session absent. Veuillez vous reconnecter.',
      );
    }

    debugPrint(
      'Appel create-admin avec JWT utilisateur.',
    );

    debugPrint(
      'Utilisateur connecté : ${session.user.id}',
    );


    //APPEL EDGE FUNCTION
    final response = await _supabase.functions.invoke(
      'create-admin',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
        'nom': nom.trim(),
        'prenom': prenom.trim(),
        'telephone': telephone.trim(),
      },
    );


    // 3. TRAITER LA REPONSE
    final data = response.data;

    debugPrint(
      'Réponse create-admin : $data',
    );

    if (data is Map) {
      final result = Map<String, dynamic>.from(data);

      if (result['success'] == true) {
        debugPrint(
          'Administrateur créé avec succès.',
        );

        return result;
      }

      throw Exception(
        result['message']?.toString() ??
            'Impossible de créer l’administrateur.',
      );
    }

    throw Exception(
      'Réponse inattendue de create-admin.',
    );
  }


  // SUPER ADMIN
  Future<bool> isSuperAdmin() async {
    final role = await getCurrentUserRole();

    return SecurityService.isSuperAdmin(role);
  }


  // PROPRIÉTAIRE
  Future<bool> isProprietaire() async {
    final role = await getCurrentUserRole();

    return SecurityService.isProprietaire(role);
  }


  // ACCÈS ESPACE PROPRIÉTAIRE
  Future<bool> canAccessOwner() async {
    final role = await getCurrentUserRole();

    return SecurityService.canAccessOwner(role);
  }


  // LOCATAIRE
  Future<bool> isLocataire() async {
    final role = await getCurrentUserRole();

    return SecurityService.isLocataire(role);
  }


  // ACCÈS ESPACE LOCATAIRE
  Future<bool> canAccessTenant() async {
    final role = await getCurrentUserRole();

    return SecurityService.canAccessTenant(role);
  }


  // CONNEXION
  Future<User?> loginWithMailPassword(
      String email,
      String password,
      ) async {
    try {
      final cleanEmail = email.trim();

      if (!SecurityService.isValidEmail(cleanEmail)) {
        throw Exception(
          'Adresse email invalide.',
        );
      }

      if (password.isEmpty) {
        throw Exception(
          'Veuillez saisir votre mot de passe.',
        );
      }

      final response =
      await _supabase.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw Exception(
          'Impossible de récupérer l’utilisateur connecté.',
        );
      }

      return user;
    } catch (e) {
      throw Exception(
        ErrorHandler.clean(e),
      );
    }
  }


  // INSCRIPTION
  Future<User?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
    required String role,
    String? adresse,
    String? urgencephone,
    String? ville,
    String? dateNaissance,
  }) async {
    try {

      // NORMALISATION
      final cleanEmail = email.trim();
      final cleanNom = nom.trim();
      final cleanPrenom = prenom.trim();
      final cleanTelephone = telephone.trim();

      final normalizedRole =
      SecurityService.normalizeRole(role);


      // VALIDATION EMAIL
      if (!SecurityService.isValidEmail(cleanEmail)) {
        throw Exception(
          'Adresse email invalide.',
        );
      }


      // VALIDATION RÔLE
      if (!SecurityService.isValidRole(
        normalizedRole,
      )) {
        throw Exception(
          'Rôle utilisateur invalide.',
        );
      }


      // VALIDATION NOM
      if (!SecurityService.isValidName(cleanNom)) {
        throw Exception(
          'Nom invalide.',
        );
      }

      // --------------------------------------------------------
      // VALIDATION PRÉNOM
      // --------------------------------------------------------

      if (!SecurityService.isValidName(cleanPrenom)) {
        throw Exception(
          'Prénom invalide.',
        );
      }


      // VALIDATION TÉLÉPHONE
      if (!SecurityService.isValidPhone(
        cleanTelephone,
      )) {
        throw Exception(
          'Numéro de téléphone invalide.',
        );
      }


      // VALIDATION ADRESSE
      if (!SecurityService.isValidAddress(
        adresse,
      )) {
        throw Exception(
          'Adresse invalide.',
        );
      }


      // VALIDATION MOT DE PASSE
      final passwordValidation =
      SecurityService.validatePasswordForRole(
        password: password,
        role: normalizedRole,
      );

      if (!passwordValidation.isValid) {
        throw Exception(
          passwordValidation.message,
        );
      }


      // INSCRIPTION SUPABASE
      final response =
      await _supabase.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {
          'nom': cleanNom,
          'prenom': cleanPrenom,
          'telephone': cleanTelephone,
          'adresse': adresse?.trim(),
          'urgencephone': urgencephone?.trim(),
          'ville': ville?.trim(),
          'date_naissance': dateNaissance,
          'role': normalizedRole,
        },
      );

      return response.user;
    } catch (e) {
      throw Exception(
        ErrorHandler.clean(e),
      );
    }
  }


  // DÉCONNEXION
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception(
        ErrorHandler.clean(e),
      );
    }
  }


  // RESET PASSWORD
  Future<void> resetPassword({
    required String email,
    String? redirectTo,
  }) async {
    try {
      final cleanEmail = email.trim();

      if (!SecurityService.isValidEmail(
        cleanEmail,
      )) {
        throw Exception(
          'Adresse email invalide.',
        );
      }

      await _supabase.auth.resetPasswordForEmail(
        cleanEmail,
        redirectTo: redirectTo,
      );
    } catch (e) {
      throw Exception(
        ErrorHandler.clean(e),
      );
    }
  }


  // SESSION
  Future<bool> refreshSessionIfNeeded() async {
    try {
      final session =
          _supabase.auth.currentSession;

      if (session == null) {
        return false;
      }

      await _supabase.auth.refreshSession();

      return _supabase.auth.currentSession != null;
    } catch (e) {
      ErrorHandler.log(
        e,
        context: 'Refresh session',
      );

      return false;
    }
  }


  // VÉRIFICATION SESSION
  Future<bool> checkSession() async {
    try {
      final session =
          _supabase.auth.currentSession;

      if (session == null) {
        return false;
      }

      final user =
          _supabase.auth.currentUser;

      return user != null;
    } catch (e) {
      ErrorHandler.log(
        e,
        context: 'Vérification session',
      );

      return false;
    }
  }


  // PROFIL
  Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;

    if (user == null) {
      return null;
    }

    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      return data;
    } catch (e) {
      throw Exception(
        ErrorHandler.clean(e),
      );
    }
  }


  // MODIFIER PROFIL
  Future<void> updateProfile({
    required String nom,
    required String prenom,
    String? telephone,
    String? adresse,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception(
        'Utilisateur non connecté.',
      );
    }

    try {
      final cleanNom = nom.trim();
      final cleanPrenom = prenom.trim();


      // VALIDATION NOM
      if (!SecurityService.isValidName(
        cleanNom,
      )) {
        throw Exception(
          'Nom invalide.',
        );
      }


      // VALIDATION PRÉNOM
      if (!SecurityService.isValidName(
        cleanPrenom,
      )) {
        throw Exception(
          'Prénom invalide.',
        );
      }


      // VALIDATION TÉLÉPHONE
      if (telephone != null &&
          !SecurityService.isValidPhone(
            telephone.trim(),
          )) {
        throw Exception(
          'Numéro de téléphone invalide.',
        );
      }


      // VALIDATION ADRESSE
      if (!SecurityService.isValidAddress(
        adresse,
      )) {
        throw Exception(
          'Adresse invalide.',
        );
      }


      // MISE À JOUR PROFILES
      await _supabase
          .from('users')
          .update({
        'nom': cleanNom,
        'prenom': cleanPrenom,
        if (telephone != null)
          'telephone': telephone.trim(),
        if (adresse != null)
          'adresse': adresse.trim(),
      }).eq(
        'id',
        user.id,
      );


      // MISE À JOUR MÉTADONNÉES SUPABASE AUTH
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'nom': cleanNom,
            'prenom': cleanPrenom,
          },
        ),
      );
    } catch (e) {
      throw Exception(
        ErrorHandler.clean(e),
      );
    }
  }


  //TÉLÉPHONE D'URGENCE
  Future<void> updatePhoneUrgence(
      String phone,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception(
        'Utilisateur non connecté.',
      );
    }

    try {
      final cleanPhone = phone.trim();

      if (!SecurityService.isValidPhone(
        cleanPhone,
      )) {
        throw Exception(
          'Numéro de téléphone invalide.',
        );
      }

      await _supabase
          .from('users')
          .update({
        'urgencephone': cleanPhone,
      }).eq(
        'id',
        user.id,
      );
    } catch (e) {
      throw Exception(
        ErrorHandler.clean(e),
      );
    }
  }


  // MISE À JOUR MOT DE PASSE
  Future<void> updatePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception(
        'Utilisateur non connecté.',
      );
    }

    //VÉRIFICATION ANCIEN MOT DE PASSE
    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: oldPassword,
      );
    } catch (e) {
      throw Exception(
        'L’ancien mot de passe est incorrect.',
      );
    }


    //RÉCUPÉRATION DU RÔLE
    final role = await getCurrentUserRole();

    if (!SecurityService.isValidRole(
      role,
    )) {
      throw Exception(
        'Rôle utilisateur invalide.',
      );
    }


    //VALIDATION NOUVEAU MOT DE PASSE
    final validation =
    SecurityService.validatePasswordForRole(
      password: newPassword,
      role: role,
    );

    if (!validation.isValid) {
      throw Exception(
        validation.message,
      );
    }


    //MISE À JOUR
    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
    } catch (e) {
      throw Exception(
        ErrorHandler.clean(e),
      );
    }
  }

  // MISE À JOUR ADRESSE
  Future<void> updateAdresseSimple(
      String adresse,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception(
        'Utilisateur non connecté.',
      );
    }

    try {
      final cleanAdresse =
      adresse.trim();

      if (!SecurityService.isValidAddress(
        cleanAdresse,
      )) {
        throw Exception(
          'Adresse invalide.',
        );
      }

      await _supabase
          .from('users')
          .update({
        'adresse': cleanAdresse,
      }).eq(
        'id',
        user.id,
      );
    } catch (e) {
      throw Exception(
        ErrorHandler.clean(e),
      );
    }
  }

  // SUPPRESSION DU COMPTE
  Future<void> deleteCurrentUserAccount() async {
    final user = currentUser;

    if (user == null) {
      throw Exception(
        'Utilisateur non connecté.',
      );
    }

    throw Exception(
      'La suppression du compte doit être effectuée '
          'via une Edge Function sécurisée.',
    );
  }
}