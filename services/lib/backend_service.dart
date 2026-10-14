// lib/services/backend_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackendService {
  BackendService({
    SupabaseClient? client,
  }) : supabase = client ?? Supabase.instance.client;


  //SUPABASE
  final SupabaseClient supabase;


  //UTILISATEUR COURANT
  User? get currentUser => supabase.auth.currentUser;

  String? get currentUserId => currentUser?.id;

  bool get isAuthenticated => currentUser != null;

  Session? get currentSession => supabase.auth.currentSession;

  bool get hasSession => currentSession != null;

  Stream<AuthState> get authStateChanges =>
      supabase.auth.onAuthStateChange;


  //PROFIL
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = currentUser;

    if (user == null) {
      return null;
    }

    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return Map<String, dynamic>.from(response);
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.getCurrentProfile: $e',
      );
      debugPrint('$stackTrace');

      return null;
    }
  }

  Future<String?> getCurrentUserRole() async {
    final user = currentUser;

    if (user == null) {
      return null;
    }

    try {
      final response = await supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      return response?['role']?.toString();
    } catch (e) {
      debugPrint(
        'BackendService.getCurrentUserRole: $e',
      );

      return null;
    }
  }

  Future<bool> isAdmin() async {
    final role = await getCurrentUserRole();

    if (role == null) {
      return false;
    }

    final normalized = role.trim().toLowerCase();

    return normalized == 'admin' ||
        normalized == 'super_admin';
  }

  Future<bool> isProprietaire() async {
    final role = await getCurrentUserRole();

    return role?.trim().toLowerCase() == 'proprietaire';
  }

  Future<bool> isLocataire() async {
    final role = await getCurrentUserRole();

    return role?.trim().toLowerCase() == 'locataire';
  }

  Future<bool> hasRole(String role) async {
    final currentRole = await getCurrentUserRole();

    if (currentRole == null) {
      return false;
    }

    return currentRole.trim().toLowerCase() ==
        role.trim().toLowerCase();
  }

  //MISE À JOUR PROFIL
  Future<void> updateProfile({
    required String nom,
    required String prenom,
    String? telephone,
    String? adresse,
    String? ville,
    String? photoProfil,
    String? description,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    final data = <String, dynamic>{
      'nom': nom.trim(),
      'prenom': prenom.trim(),
    };

    if (telephone != null) {
      data['telephone'] = telephone.trim();
    }

    if (adresse != null) {
      data['adresse'] = adresse.trim();
    }

    if (ville != null) {
      data['ville'] = ville.trim();
    }

    if (photoProfil != null) {
      data['photo_profil'] = photoProfil.trim();
    }

    if (description != null) {
      data['description'] = description.trim();
    }

    try {
      await supabase
          .from('users')
          .update(data)
          .eq('id', user.id);

      debugPrint('Profil mis à jour');
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.updateProfile: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  Future<void> updatePhoneUrgence(
      String urgencePhone,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      await supabase
          .from('users')
          .update({
        'urgencephone': urgencePhone.trim(),
      })
          .eq('id', user.id);

      debugPrint(
        'Téléphone d’urgence mis à jour',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.updatePhoneUrgence: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  Future<void> updateAdresse(String adresse) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      await supabase
          .from('users')
          .update({
        'adresse': adresse.trim(),
      })
          .eq('id', user.id);

      debugPrint('Adresse mise à jour');
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.updateAdresse: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  //MOT DE PASSE
  Future<void> updatePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    if (newPassword.length < 6) {
      throw Exception(
        'Le nouveau mot de passe doit contenir au moins 6 caractères.',
      );
    }

    try {
      final response =
      await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: oldPassword,
      );

      if (response.user == null) {
        throw Exception(
          'Ancien mot de passe incorrect.',
        );
      }

      await supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );

      debugPrint('Mot de passe modifié');
    } on AuthException catch (e) {
      debugPrint(
        'AuthException updatePassword: ${e.message}',
      );

      throw Exception(e.message);
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.updatePassword: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  // SUPPRESSION COMPTE
  Future<void> deleteCurrentUserAccount() async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {

      await supabase
          .from('users')
          .delete()
          .eq('id', user.id);

      await supabase.auth.signOut();

      debugPrint(
        'Profil utilisateur supprimé',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.deleteCurrentUserAccount: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  //SESSION
  Future<bool> refreshSessionIfNeeded() async {
    try {
      final session = supabase.auth.currentSession;

      if (session == null) {
        return false;
      }

      await supabase.auth.refreshSession();

      return supabase.auth.currentSession != null;
    } on AuthException catch (e) {
      debugPrint(
        'Erreur refresh session: ${e.message}',
      );

      return false;
    } catch (e) {
      debugPrint(
        'Erreur refresh session: $e',
      );

      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();

      debugPrint('Déconnexion réussie');
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.signOut: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  //APPARTEMENTS

  // CRÉER UN APPARTEMENT
  Future<Map<String, dynamic>> createApartment({
    required String titre,
    required String description,
    required String type,
    required String ville,
    required String adresse,
    required double prix,
    double? prixProprietaire,
    String? nbreSejour,
    List<String> equipements = const [],
    Map<String, bool> reglesSejour = const {},
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      final data = <String, dynamic>{
        'proprietaire_id': user.id,
        'titre': titre.trim(),
        'description': description.trim(),
        'type': type.trim(),
        'ville': ville.trim(),
        'adresse': adresse.trim(),
        'prix': prix,
        'prix_proprietaire':
        prixProprietaire ?? prix,

        'nbre_sejour':
        nbreSejour?.trim() ?? 'nuit',

        'status': 'en_attente',

        'rating': 0,
        'ratings_count': 0,

        'autres_equipements': {
          'equipements': equipements,
          'regles_sejour': reglesSejour,
        },
      };

      final response = await supabase
          .from('appartements')
          .insert(data)
          .select()
          .single();

      final appartement =
      Map<String, dynamic>.from(response);

      debugPrint(
        'Appartement créé : ${appartement['id']}',
      );

      return appartement;
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.createApartment: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  //MODIFIER UN APPARTEMENT
  Future<Map<String, dynamic>> updateApartment({
    required String apartmentId,
    String? titre,
    String? description,
    String? type,
    String? ville,
    String? adresse,
    double? prix,
    double? prixProprietaire,
    String? nbreSejour,
    List<String>? equipements,
    Map<String, bool>? reglesSejour,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    final data = <String, dynamic>{};

    if (titre != null) {
      data['titre'] = titre.trim();
    }

    if (description != null) {
      data['description'] = description.trim();
    }

    if (type != null) {
      data['type'] = type.trim();
    }

    if (ville != null) {
      data['ville'] = ville.trim();
    }

    if (adresse != null) {
      data['adresse'] = adresse.trim();
    }

    if (prix != null) {
      data['prix'] = prix;
    }

    if (prixProprietaire != null) {
      data['prix_proprietaire'] =
          prixProprietaire;
    }

    if (nbreSejour != null) {
      data['nbre_sejour'] =
          nbreSejour.trim();
    }

    if (equipements != null ||
        reglesSejour != null) {
      final existing =
      await getApartmentById(apartmentId);

      final oldEquipment =
      _extractEquipements(
        existing?['autres_equipements'],
      );

      final oldRules =
      _extractRegles(
        existing?['autres_equipements'],
      );

      data['autres_equipements'] = {
        'equipements':
        equipements ?? oldEquipment,
        'regles_sejour':
        reglesSejour ?? oldRules,
      };
    }

    if (data.isEmpty) {
      throw Exception(
        'Aucune donnée à modifier.',
      );
    }

    try {
      final response = await supabase
          .from('appartements')
          .update(data)
          .eq('id', apartmentId)
          .eq('proprietaire_id', user.id)
          .select()
          .single();

      debugPrint(
        'Appartement modifié : $apartmentId',
      );

      return Map<String, dynamic>.from(
        response,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.updateApartment: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  //RÉCUPÉRER UN APPARTEMENT
  Future<Map<String, dynamic>?>
  getApartmentById(
      String apartmentId,
      ) async {
    try {
      final response = await supabase
          .from('appartements')
          .select('''
            *,
            photo_appartements (
              id,
              appartement_id,
              fichiername,
              extension,
              taille_bytes,
              titre,
              est_principale,
              ordre_affichage,
              uploaded_at
            ),
            appartement_infos (
              id,
              appartement_id,
              chambre,
              salon,
              douche,
              cuisine,
              etage,
              taille,
              service_inclus,
              internet,
              stationnement,
              meuble,
              climatisation,
              created_at,
              updated_at
            )
          ''')
          .eq('id', apartmentId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return Map<String, dynamic>.from(
        response,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.getApartmentById: $e',
      );
      debugPrint('$stackTrace');

      return null;
    }
  }

  // APPARTEMENTS PUBLICS
  Future<List<Map<String, dynamic>>>
  getPublishedApartments({
    String? ville,
    String? type,
  }) async {
    try {
      var query = supabase
          .from('appartements')
          .select('''
            *,
            photo_appartements (
              id,
              fichiername,
              extension,
              titre,
              est_principale,
              ordre_affichage
            ),
            appartement_infos (
              id,
              chambre,
              salon,
              douche,
              cuisine,
              etage,
              taille,
              service_inclus,
              internet,
              stationnement,
              meuble,
              climatisation
            )
          ''')
          .eq('status', 'publie');

      if (ville != null &&
          ville.trim().isNotEmpty &&
          ville != 'Toutes') {
        query = query.eq(
          'ville',
          ville.trim(),
        );
      }

      if (type != null &&
          type.trim().isNotEmpty &&
          type != 'Tous') {
        query = query.eq(
          'type',
          type.trim(),
        );
      }

      final response =
      await query.order(
        'created_at',
        ascending: false,
      );

      return List<Map<String, dynamic>>.from(
        response,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.getPublishedApartments: $e',
      );
      debugPrint('$stackTrace');

      return [];
    }
  }

  //APPARTEMENTS DU PROPRIÉTAIRE
  Future<List<Map<String, dynamic>>>
  getOwnerApartments() async {
    final user = currentUser;

    if (user == null) {
      return [];
    }

    try {
      final response = await supabase
          .from('appartements')
          .select('''
            id,
            proprietaire_id,
            titre,
            description,
            type,
            prix,
            prix_proprietaire,
            nbre_sejour,
            status,
            disponibilite_status,
            validated_by,
            validated_at,
            refusal_reason,
            autres_equipements,
            rating,
            ratings_count,
            created_at,
            updated_at,
            photo_appartements (
              id,
              appartement_id,
              fichiername,
              extension,
              taille_bytes,
              titre,
              est_principale,
              ordre_affichage,
              uploaded_at
            ),
            appartement_infos (
              id,
              appartement_id,
              chambre,
              salon,
              douche,
              cuisine,
              etage,
              taille,
              service_inclus,
              internet,
              stationnement,
              meuble,
              climatisation
            )
          ''')
          .eq(
        'proprietaire_id',
        user.id,
      )
          .order(
        'created_at',
        ascending: false,
      );

      return List<Map<String, dynamic>>.from(
        response,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.getOwnerApartments: $e',
      );
      debugPrint('$stackTrace');

      return [];
    }
  }

  // SUPPRIMER APPARTEMENT
  Future<void> deleteApartment(
      String apartmentId,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      await supabase
          .from('appartements')
          .delete()
          .eq('id', apartmentId)
          .eq('proprietaire_id', user.id);

      debugPrint(
        'Appartement supprimé : $apartmentId',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.deleteApartment: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  // SOUMETTRE À NOUVEAU
  Future<void> resubmitApartment(
      String apartmentId,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      await supabase
          .from('appartements')
          .update({
        'status': 'en_attente',
        'refusal_reason': null,
        'validated_by': null,
        'validated_at': null,
      })
          .eq('id', apartmentId)
          .eq('proprietaire_id', user.id);

      debugPrint(
        'Appartement resoumis : $apartmentId',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.resubmitApartment: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  //ADMIN VALIDATION
  Future<void> approveApartment(
      String apartmentId,
      ) async {
    if (!await isAdmin()) {
      throw Exception(
        'Accès refusé : administrateur requis.',
      );
    }

    final admin = currentUser;

    if (admin == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      await supabase
          .from('appartements')
          .update({
        'status': 'publie',
        'validated_by': admin.id,
        'validated_at':
        DateTime.now().toIso8601String(),
        'refusal_reason': null,
      })
          .eq('id', apartmentId);

      debugPrint(
        'Appartement validé : $apartmentId',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.approveApartment: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  //ADMIN REFUSER
  Future<void> rejectApartment({
    required String apartmentId,
    required String reason,
  }) async {
    if (!await isAdmin()) {
      throw Exception(
        'Accès refusé : administrateur requis.',
      );
    }

    final admin = currentUser;

    if (admin == null) {
      throw Exception('Utilisateur non connecté.');
    }

    if (reason.trim().isEmpty) {
      throw Exception(
        'Le motif du refus est obligatoire.',
      );
    }

    try {
      await supabase
          .from('appartements')
          .update({
        'status': 'refuse',
        'validated_by': admin.id,
        'validated_at':
        DateTime.now().toIso8601String(),
        'refusal_reason':
        reason.trim(),
      })
          .eq('id', apartmentId);

      debugPrint(
        'Appartement refusé : $apartmentId',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.rejectApartment: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }


  //ADMIN APPARTEMENTS EN ATTENTE
  Future<List<Map<String, dynamic>>>
  getPendingApartments() async {
    if (!await isAdmin()) {
      throw Exception(
        'Accès refusé : administrateur requis.',
      );
    }

    try {
      final response = await supabase
          .from('appartements')
          .select('''
            *,
            users:proprietaire_id (
              id,
              nom,
              prenom,
              email,
              telephone,
              photo_profil,
              est_certifie,
              identite_verifiee
            ),
            photo_appartements (
              id,
              fichiername,
              extension,
              titre,
              est_principale,
              ordre_affichage
            ),
            appartement_infos (
              id,
              chambre,
              salon,
              douche,
              cuisine,
              etage,
              taille,
              service_inclus,
              internet,
              stationnement,
              meuble,
              climatisation
            )
          ''')
          .eq('status', 'en_attente')
          .order(
        'created_at',
        ascending: true,
      );

      return List<Map<String, dynamic>>.from(
        response,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.getPendingApartments: $e',
      );
      debugPrint('$stackTrace');

      return [];
    }
  }

  //ADMIN TOUS LES APPARTEMENTS
  Future<List<Map<String, dynamic>>>
  getAllApartmentsForAdmin() async {
    if (!await isAdmin()) {
      throw Exception(
        'Accès refusé : administrateur requis.',
      );
    }

    try {
      final response = await supabase
          .from('appartements')
          .select('''
            *,
            users:proprietaire_id (
              id,
              nom,
              prenom,
              email,
              telephone,
              role
            ),
            photo_appartements (
              id,
              fichiername,
              extension,
              titre,
              est_principale,
              ordre_affichage
            )
          ''')
          .order(
        'created_at',
        ascending: false,
      );

      return List<Map<String, dynamic>>.from(
        response,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.getAllApartmentsForAdmin: $e',
      );
      debugPrint('$stackTrace');

      return [];
    }
  }

  //APPARTEMENT INFOS
  Future<Map<String, dynamic>?>
  getApartmentInfos(
      String apartmentId,
      ) async {
    try {
      final response = await supabase
          .from('appartement_infos')
          .select()
          .eq(
        'appartement_id',
        apartmentId,
      )
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return Map<String, dynamic>.from(
        response,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.getApartmentInfos: $e',
      );
      debugPrint('$stackTrace');

      return null;
    }
  }

  Future<Map<String, dynamic>>
  saveApartmentInfos({
    required String apartmentId,
    required int chambre,
    required int salon,
    required int douche,
    required int cuisine,
    required int etage,
    required double taille,
    required String serviceInclus,
    required String internet,
    required String stationnement,
    required String meuble,
    required String climatisation,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      final data = {
        'appartement_id': apartmentId,
        'chambre': chambre,
        'salon': salon,
        'douche': douche,
        'cuisine': cuisine,
        'etage': etage,
        'taille': taille,
        'service_inclus': serviceInclus,
        'internet': internet,
        'stationnement': stationnement,
        'meuble': meuble,
        'climatisation': climatisation,
      };

      final response = await supabase
          .from('appartement_infos')
          .upsert(
        data,
        onConflict: 'appartement_id',
      )
          .select()
          .single();

      debugPrint(
        'Informations appartement enregistrées',
      );

      return Map<String, dynamic>.from(
        response,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.saveApartmentInfos: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  Future<void> deleteApartmentInfos(
      String apartmentId,
      ) async {
    try {
      await supabase
          .from('appartement_infos')
          .delete()
          .eq(
        'appartement_id',
        apartmentId,
      );

      debugPrint(
        'Informations appartement supprimées',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.deleteApartmentInfos: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  //PHOTOS
  Future<List<Map<String, dynamic>>>
  getApartmentPhotos(
      String apartmentId,
      ) async {
    try {
      final response = await supabase
          .from('photo_appartements')
          .select()
          .eq(
        'appartement_id',
        apartmentId,
      )
          .order(
        'ordre_affichage',
        ascending: true,
      );

      return List<Map<String, dynamic>>.from(
        response,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.getApartmentPhotos: $e',
      );
      debugPrint('$stackTrace');

      return [];
    }
  }

  Future<Map<String, dynamic>> addApartmentPhoto({
    required String apartmentId,
    required String fichiername,
    String? extension,
    int? tailleBytes,
    String? titre,
    bool estPrincipale = false,
    int ordreAffichage = 0,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      //Vérifier que l'appartement appartient au propriétaire
      final apartment = await supabase
          .from('appartements')
          .select('id')
          .eq('id', apartmentId)
          .eq('proprietaire_id', user.id)
          .maybeSingle();

      if (apartment == null) {
        throw Exception(
          'Vous n’êtes pas propriétaire de cet appartement.',
        );
      }

      if (estPrincipale) {
        await supabase
            .from('photo_appartements')
            .update({
          'est_principale': false,
        })
            .eq(
          'appartement_id',
          apartmentId,
        );
      }

      final data = {
        'appartement_id': apartmentId,
        'fichiername': fichiername.trim(),
        'extension': extension?.trim(),
        'taille_bytes': tailleBytes,
        'titre': titre?.trim(),
        'est_principale': estPrincipale,
        'ordre_affichage': ordreAffichage,
      };

      final response = await supabase
          .from('photo_appartements')
          .insert(data)
          .select()
          .single();

      debugPrint('Photo ajoutée');

      return Map<String, dynamic>.from(response);
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.addApartmentPhoto: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  Future<void> updateApartmentPhoto({
    required String photoId,
    String? titre,
    bool? estPrincipale,
    int? ordreAffichage,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    final data = <String, dynamic>{};

    if (titre != null) {
      data['titre'] = titre.trim();
    }

    if (ordreAffichage != null) {
      data['ordre_affichage'] = ordreAffichage;
    }

    try {
      final photo = await supabase
          .from('photo_appartements')
          .select('appartement_id')
          .eq('id', photoId)
          .maybeSingle();

      if (photo == null) {
        throw Exception('Photo introuvable.');
      }

      final apartmentId =
      photo['appartement_id']?.toString();

      if (apartmentId == null) {
        throw Exception(
          'Appartement associé à la photo introuvable.',
        );
      }

      //Vérifier le propriétaire
      final apartment = await supabase
          .from('appartements')
          .select('id')
          .eq('id', apartmentId)
          .eq('proprietaire_id', user.id)
          .maybeSingle();

      if (apartment == null) {
        throw Exception(
          'Vous n’êtes pas propriétaire de cet appartement.',
        );
      }

      if (estPrincipale == true) {
        await supabase
            .from('photo_appartements')
            .update({
          'est_principale': false,
        })
            .eq(
          'appartement_id',
          apartmentId,
        );

        data['est_principale'] = true;
      } else if (estPrincipale == false) {
        data['est_principale'] = false;
      }

      if (data.isEmpty) {
        return;
      }

      await supabase
          .from('photo_appartements')
          .update(data)
          .eq('id', photoId);

      debugPrint('Photo modifiée');
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.updateApartmentPhoto: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  Future<void> deleteApartmentPhoto(
      String photoId,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      final photo = await supabase
          .from('photo_appartements')
          .select('appartement_id')
          .eq('id', photoId)
          .maybeSingle();

      if (photo == null) {
        throw Exception('Photo introuvable.');
      }

      final apartmentId =
      photo['appartement_id']?.toString();

      if (apartmentId == null) {
        throw Exception(
          'Appartement associé introuvable.',
        );
      }

      final apartment = await supabase
          .from('appartements')
          .select('id')
          .eq('id', apartmentId)
          .eq('proprietaire_id', user.id)
          .maybeSingle();

      if (apartment == null) {
        throw Exception(
          'Vous n’êtes pas propriétaire de cet appartement.',
        );
      }

      await supabase
          .from('photo_appartements')
          .delete()
          .eq('id', photoId);

      debugPrint('Photo supprimée');
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.deleteApartmentPhoto: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  // DISPONIBILITÉS
  Future<List<Map<String, dynamic>>>
  getApartmentAvailability(
      String apartmentId,
      ) async {
    try {
      final response = await supabase
          .from('disponibilites')
          .select()
          .eq(
        'appartement_id',
        apartmentId,
      )
          .order(
        'date_debut',
        ascending: true,
      );

      return List<Map<String, dynamic>>.from(
        response,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.getApartmentAvailability: $e',
      );
      debugPrint('$stackTrace');

      return [];
    }
  }

  Future<Map<String, dynamic>>
  createAvailability({
    required String apartmentId,
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    if (dateFin.isBefore(dateDebut)) {
      throw Exception(
        'La date de fin doit être supérieure ou égale à la date de début.',
      );
    }

    try {
      final data = {
        'appartement_id': apartmentId,
        'proprietaire_id': user.id,
        'date_debut':
        _dateOnly(dateDebut),
        'date_fin':
        _dateOnly(dateFin),
      };

      final response = await supabase
          .from('disponibilites')
          .insert(data)
          .select()
          .single();

      debugPrint(
        'Disponibilité créée',
      );

      return Map<String, dynamic>.from(
        response,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.createAvailability: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  Future<void> updateAvailability({
    required String availabilityId,
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    if (dateFin.isBefore(dateDebut)) {
      throw Exception(
        'La date de fin doit être supérieure ou égale à la date de début.',
      );
    }

    try {
      await supabase
          .from('disponibilites')
          .update({
        'date_debut':
        _dateOnly(dateDebut),
        'date_fin':
        _dateOnly(dateFin),
      })
          .eq(
        'id',
        availabilityId,
      );

      debugPrint(
        'Disponibilité modifiée',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.updateAvailability: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  Future<void> deleteAvailability(
      String availabilityId,
      ) async {
    try {
      await supabase
          .from('disponibilites')
          .delete()
          .eq(
        'id',
        availabilityId,
      );

      debugPrint(
        'Disponibilité supprimée',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.deleteAvailability: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  Future<bool> isApartmentAvailable({
    required String apartmentId,
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    try {
      final response = await supabase
          .from('disponibilites')
          .select('id')
          .eq(
        'appartement_id',
        apartmentId,
      )
          .lte(
        'date_debut',
        _dateOnly(dateFin),
      )
          .gte(
        'date_fin',
        _dateOnly(dateDebut),
      )
          .limit(1);

      return response.isNotEmpty;
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.isApartmentAvailable: $e',
      );
      debugPrint('$stackTrace');

      return false;
    }
  }


  // RÉSERVATIONS
  Future<Map<String, dynamic>>
  createReservation({
    required String apartmentId,
    required String proprietaireId,
    required DateTime dateDebut,
    required DateTime dateFin,
    required String momentPaiement,
    String? methodePaiement,
    int adulte = 1,
    int enfant = 0,
    required double prixTotal,
    required double prixProprietaire,
    required double fraisService,
    double reduction = 0,
    String? message,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    if (dateFin.isBefore(dateDebut) ||
        dateFin.isAtSameMomentAs(dateDebut)) {
      throw Exception(
        'Les dates de réservation sont invalides.',
      );
    }

    if (adulte < 1) {
      throw Exception(
        'Le nombre d’adultes doit être au moins égal à 1.',
      );
    }

    if (enfant < 0) {
      throw Exception(
        'Le nombre d’enfants ne peut pas être négatif.',
      );
    }

    if (momentPaiement != 'maintenant' &&
        momentPaiement != 'arrivee') {
      throw Exception(
        'Moment de paiement invalide.',
      );
    }

    try {
      final available =
      await isApartmentAvailable(
        apartmentId: apartmentId,
        dateDebut: dateDebut,
        dateFin: dateFin,
      );

      if (!available) {
        throw Exception(
          'L’appartement n’est pas disponible pour ces dates.',
        );
      }

      // Vérification des réservations déjà confirmées.
      final conflicts = await supabase
          .from('reservations')
          .select('id')
          .eq(
        'appartement_id',
        apartmentId,
      )
          .inFilter(
        'statut',
        [
          'en_attente',
          'confirmee',
        ],
      )
          .lt(
        'date_debut',
        _dateOnly(dateFin),
      )
          .gt(
        'date_fin',
        _dateOnly(dateDebut),
      );

      if (conflicts.isNotEmpty) {
        throw Exception(
          'Une réservation existe déjà pour cette période.',
        );
      }

      final data = {
        'appartement_id': apartmentId,
        'locataire_id': user.id,
        'proprietaire_id': proprietaireId,
        'date_debut':
        _dateOnly(dateDebut),
        'date_fin':
        _dateOnly(dateFin),
        'moment_paiement':
        momentPaiement,
        'methode_paiement':
        methodePaiement,
        'adulte': adulte,
        'enfant': enfant,
        'prix_total': prixTotal,
        'prix_proprietaire':
        prixProprietaire,
        'frais_service': fraisService,
        'reduction': reduction,
        'statut': 'en_attente',
        'message': message?.trim(),
      };

      final response = await supabase
          .from('reservations')
          .insert(data)
          .select()
          .single();

      debugPrint(
        'Réservation créée',
      );

      return Map<String, dynamic>.from(
        response,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.createReservation: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }


  //MES RÉSERVATIONS LOCATAIRE
  Future<List<Map<String, dynamic>>>
  getMyReservations() async {
    final user = currentUser;

    if (user == null) {
      return [];
    }

    try {
      final response = await supabase
          .from('reservations')
          .select('''
            *,
            appartements (
              id,
              titre,
              ville,
              adresse,
              prix,
              photo_appartements (
                id,
                fichiername,
                est_principale,
                ordre_affichage
              )
            )
          ''')
          .eq(
        'locataire_id',
        user.id,
      )
          .order(
        'created_at',
        ascending: false,
      );

      return List<Map<String, dynamic>>.from(
        response,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.getMyReservations: $e',
      );
      debugPrint('$stackTrace');

      return [];
    }
  }


  // RÉSERVATIONS PROPRIÉTAIRE
  Future<List<Map<String, dynamic>>>
  getOwnerReservations() async {
    final user = currentUser;

    if (user == null) {
      return [];
    }

    try {
      final response = await supabase
          .from('reservations')
          .select('''
            *,
            appartements (
              id,
              titre,
              ville,
              adresse
            ),
            users:locataire_id (
              id,
              nom,
              prenom,
              email,
              telephone,
              photo_profil
            )
          ''')
          .eq(
        'proprietaire_id',
        user.id,
      )
          .order(
        'created_at',
        ascending: false,
      );

      return List<Map<String, dynamic>>.from(
        response,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.getOwnerReservations: $e',
      );
      debugPrint('$stackTrace');

      return [];
    }
  }


  // RÉSERVATION PAR ID
  Future<Map<String, dynamic>?>
  getReservationById(
      String reservationId,
      ) async {
    try {
      final response = await supabase
          .from('reservations')
          .select('''
            *,
            appartements (
              id,
              titre,
              ville,
              adresse,
              prix
            ),
            users:locataire_id (
              id,
              nom,
              prenom,
              email,
              telephone,
              photo_profil
            )
          ''')
          .eq(
        'id',
        reservationId,
      )
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return Map<String, dynamic>.from(
        response,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.getReservationById: $e',
      );
      debugPrint('$stackTrace');

      return null;
    }
  }


  // CONFIRMER RÉSERVATION
  Future<void> confirmReservation(
      String reservationId,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      await supabase
          .from('reservations')
          .update({
        'statut': 'confirmee',
      })
          .eq(
        'id',
        reservationId,
      )
          .eq(
        'proprietaire_id',
        user.id,
      );

      debugPrint(
        'Réservation confirmée',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.confirmReservation: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }


  //REFUSER RÉSERVATION
  Future<void> rejectReservation(
      String reservationId,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      await supabase
          .from('reservations')
          .update({
        'statut': 'refuse',
      })
          .eq(
        'id',
        reservationId,
      )
          .eq(
        'proprietaire_id',
        user.id,
      );

      debugPrint(
        'Réservation refusée',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.rejectReservation: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }


  // ANNULER RÉSERVATION
  Future<void> cancelReservation(
      String reservationId,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      final reservation = await getReservationById(
        reservationId,
      );

      if (reservation == null) {
        throw Exception(
          'Réservation introuvable.',
        );
      }

      final locataireId =
      reservation['locataire_id']
          ?.toString();

      final proprietaireId =
      reservation['proprietaire_id']
          ?.toString();

      if (locataireId != user.id &&
          proprietaireId != user.id) {
        throw Exception(
          'Vous n’avez pas le droit d’annuler cette réservation.',
        );
      }

      await supabase
          .from('reservations')
          .update({
        'statut': 'annulee',
      })
          .eq(
        'id',
        reservationId,
      );

      debugPrint(
        'Réservation annulée',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.cancelReservation: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }


  // TERMINER RÉSERVATION
  Future<void> completeReservation(
      String reservationId,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      await supabase
          .from('reservations')
          .update({
        'statut': 'terminee',
      })
          .eq(
        'id',
        reservationId,
      )
          .eq(
        'proprietaire_id',
        user.id,
      );

      debugPrint(
        'Réservation terminée',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.completeReservation: $e',
      );
      debugPrint('$stackTrace');

      rethrow;
    }
  }


  // DASHBOARD PROPRIÉTAIRE
  Future<Map<String, dynamic>>
  getOwnerDashboardStats() async {
    final user = currentUser;

    if (user == null) {
      return _emptyOwnerDashboardStats();
    }

    try {
      final appartementsResponse =
      await supabase
          .from('appartements')
          .select('''
                id,
                titre,
                prix,
                prix_proprietaire,
                status,
                rating,
                ratings_count
              ''')
          .eq(
        'proprietaire_id',
        user.id,
      );

      final appartements =
      List<Map<String, dynamic>>.from(
        appartementsResponse,
      );

      final villes = appartements
          .map(
            (e) => e['ville']
            ?.toString()
            .trim(),
      )
          .where(
            (v) =>
        v != null &&
            v.isNotEmpty,
      )
          .toSet();

      final reservationsResponse =
      await supabase
          .from('reservations')
          .select('''
                id,
                appartement_id,
                proprietaire_id,
                date_debut,
                date_fin,
                prix_total,
                prix_proprietaire,
                frais_service,
                reduction,
                statut,
                created_at
              ''')
          .eq(
        'proprietaire_id',
        user.id,
      );

      final reservations =
      List<Map<String, dynamic>>.from(
        reservationsResponse,
      );


      // NOTE GLOBALE
      double totalRating = 0;
      int totalAvis = 0;

      for (final appartement in appartements) {
        final rating = appartement['rating'];
        final count =
        appartement['ratings_count'];

        if (rating is num &&
            count is num &&
            count.toInt() > 0) {
          totalRating +=
              rating.toDouble() *
                  count.toInt();

          totalAvis += count.toInt();
        }
      }

      final note = totalAvis > 0
          ? totalRating / totalAvis
          : 0.0;

      // MOIS
      final now = DateTime.now();

      final debutMois = DateTime(
        now.year,
        now.month,
        1,
      );

      final debutMoisSuivant = DateTime(
        now.year,
        now.month + 1,
        1,
      );

      final debutMoisPrecedent = DateTime(
        now.year,
        now.month - 1,
        1,
      );

      final joursDansLeMois =
          debutMoisSuivant
              .difference(debutMois)
              .inDays;


      // RÉSERVATIONS ACTIVES
      final reservationsActives =
          reservations.where((r) {
            final statut = _normalize(
              r['statut'],
            );

            return statut == 'en_attente' ||
                statut == 'confirmee';
          }).length;


      // REVENUS
      final revenusMois =
      _calculateRevenueForPeriod(
        reservations,
        debutMois,
        debutMoisSuivant,
      );

      final revenusMoisPrecedent =
      _calculateRevenueForPeriod(
        reservations,
        debutMoisPrecedent,
        debutMois,
      );

      double evolutionRevenus = 0;

      if (revenusMoisPrecedent > 0) {
        evolutionRevenus =
            ((revenusMois -
                revenusMoisPrecedent) /
                revenusMoisPrecedent) *
                100;
      } else if (revenusMois > 0) {
        evolutionRevenus = 100;
      }


      // RÉSERVATIONS DU MOIS
      final reservationsMois =
          reservations.where((r) {
            final statut = _normalize(
              r['statut'],
            );

            if (statut != 'en_attente' &&
                statut != 'confirmee') {
              return false;
            }

            final debut =
            _parseDate(r['date_debut']);

            final fin =
            _parseDate(r['date_fin']);

            if (debut == null || fin == null) {
              return false;
            }

            return debut.isBefore(
              debutMoisSuivant,
            ) &&
                fin.isAfter(debutMois);
          }).length;

      // OCCUPATION
      final Set<String> joursOccupes = {};

      for (final reservation
      in reservations) {
        final statut = _normalize(
          reservation['statut'],
        );

        if (statut != 'confirmee' &&
            statut != 'terminee') {
          continue;
        }

        final apartmentId =
        reservation['appartement_id']
            ?.toString();

        final debut =
        _parseDate(
          reservation['date_debut'],
        );

        final fin =
        _parseDate(
          reservation['date_fin'],
        );

        if (apartmentId == null ||
            debut == null ||
            fin == null) {
          continue;
        }

        final start =
        debut.isAfter(debutMois)
            ? debut
            : debutMois;

        final end =
        fin.isBefore(
          debutMoisSuivant,
        )
            ? fin
            : debutMoisSuivant;

        if (!start.isBefore(end)) {
          continue;
        }

        var jour = start;

        while (jour.isBefore(end)) {
          final key =
              '${apartmentId}_${jour.year}-${jour.month}-${jour.day}';

          joursOccupes.add(key);

          jour = jour.add(
            const Duration(days: 1),
          );
        }
      }

      final nuitsOccupees =
          joursOccupes.length;

      final nuitsDisponibles =
          appartements.length *
              joursDansLeMois;

      final tauxOccupation =
      nuitsDisponibles > 0
          ? ((nuitsOccupees /
          nuitsDisponibles) *
          100)
          .clamp(0.0, 100.0)
          : 0.0;

      return {
        'revenus': revenusMois,
        'revenus_mois_precedent':
        revenusMoisPrecedent,
        'evolution_revenus':
        evolutionRevenus,

        'reservations':
        reservationsActives,
        'reservations_mois':
        reservationsMois,

        'taux_occupation':
        tauxOccupation,

        'nuits_occupees':
        nuitsOccupees,

        'nuits_disponibles':
        nuitsDisponibles,

        'note': note,
        'avis': totalAvis,

        'biens': appartements.length,
        'villes': villes.length,

        'mois': now.month,
        'annee': now.year,
      };
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.getOwnerDashboardStats: $e',
      );
      debugPrint('$stackTrace');

      return _emptyOwnerDashboardStats();
    }
  }


  // REVENUS PROPRIÉTAIRE
  Future<Map<String, dynamic>>
  getOwnerRevenueData({
    int? year,
    int? month,
  }) async {
    final user = currentUser;

    final targetYear =
        year ?? DateTime.now().year;

    final targetMonth =
        month ?? DateTime.now().month;

    if (user == null) {
      return _emptyOwnerRevenueData(
        targetYear,
        targetMonth,
      );
    }

    try {
      final appartementsResponse =
      await supabase
          .from('appartements')
          .select('id, titre')
          .eq(
        'proprietaire_id',
        user.id,
      );

      final appartements =
      List<Map<String, dynamic>>.from(
        appartementsResponse,
      );

      final appartementNames =
      <String, String>{};

      for (final appartement
      in appartements) {
        final id =
        appartement['id']?.toString();

        if (id != null) {
          appartementNames[id] =
              appartement['titre']
                  ?.toString() ??
                  'Appartement';
        }
      }

      final reservationsResponse =
      await supabase
          .from('reservations')
          .select('''
                id,
                appartement_id,
                date_debut,
                date_fin,
                prix_total,
                prix_proprietaire,
                frais_service,
                reduction,
                statut,
                created_at
              ''')
          .eq(
        'proprietaire_id',
        user.id,
      )
          .order(
        'date_debut',
        ascending: false,
      );

      final reservations =
      List<Map<String, dynamic>>.from(
        reservationsResponse,
      );

      final monthlyRevenue =
      List<double>.filled(12, 0);

      final revenueByApartment =
      <String, double>{};

      final transactions =
      <Map<String, dynamic>>[];

      final currentMonthStart =
      DateTime(
        targetYear,
        targetMonth,
        1,
      );

      final currentMonthEnd =
      DateTime(
        targetYear,
        targetMonth + 1,
        1,
      );

      final previousMonthStart =
      DateTime(
        targetYear,
        targetMonth - 1,
        1,
      );

      final previousMonthEnd =
      DateTime(
        targetYear,
        targetMonth,
        1,
      );

      double currentMonthRevenue = 0;
      double previousMonthRevenue = 0;

      int nightsCurrentMonth = 0;

      for (final reservation
      in reservations) {
        final statut = _normalize(
          reservation['statut'],
        );

        if (statut != 'confirmee' &&
            statut != 'terminee') {
          continue;
        }

        final dateDebut =
        _parseDate(
          reservation['date_debut'],
        );

        final dateFin =
        _parseDate(
          reservation['date_fin'],
        );

        if (dateDebut == null ||
            dateFin == null) {
          continue;
        }

        final prix =
        _toDouble(
          reservation[
          'prix_proprietaire'],
        );

        if (prix <= 0) {
          continue;
        }

        final appartementId =
        reservation['appartement_id']
            ?.toString();

        final appartementNom =
            appartementNames[
            appartementId] ??
                'Appartement';


        // Revenus annuels
        if (dateDebut.year ==
            targetYear) {
          monthlyRevenue[
          dateDebut.month - 1] +=
              prix;

          revenueByApartment[
          appartementNom] =
              (revenueByApartment[
              appartementNom] ??
                  0) +
                  prix;
        }


        // Mois courant
        if (!dateDebut.isBefore(
          currentMonthStart,
        ) &&
            dateDebut.isBefore(
              currentMonthEnd,
            )) {
          currentMonthRevenue += prix;

          final nights =
              dateFin
                  .difference(dateDebut)
                  .inDays;

          if (nights > 0) {
            nightsCurrentMonth +=
                nights;
          }

          transactions.add({
            'id':
            reservation['id'],
            'name':
            'Réservation',
            'apt':
            appartementNom,
            'date':
            dateDebut,
            'amount':
            prix,
            'type':
            'credit',
            'reservation_id':
            reservation['id'],
          });
        }


        // Mois précédent
        if (!dateDebut.isBefore(
          previousMonthStart,
        ) &&
            dateDebut.isBefore(
              previousMonthEnd,
            )) {
          previousMonthRevenue +=
              prix;
        }
      }

      final totalYearRevenue =
      monthlyRevenue.fold<double>(
        0,
            (sum, value) =>
        sum + value,
      );

      final byApartment =
      <Map<String, dynamic>>[];

      revenueByApartment
          .forEach((name, revenue) {
        final percentage =
        totalYearRevenue > 0
            ? (revenue /
            totalYearRevenue) *
            100
            : 0.0;

        byApartment.add({
          'name': name,
          'revenue': revenue,
          'pct': percentage,
        });
      });

      byApartment.sort(
            (a, b) =>
            (b['revenue'] as double)
                .compareTo(
              a['revenue'] as double,
            ),
      );

      double evolution = 0;

      if (previousMonthRevenue > 0) {
        evolution =
            ((currentMonthRevenue -
                previousMonthRevenue) /
                previousMonthRevenue) *
                100;
      } else if (currentMonthRevenue > 0) {
        evolution = 100;
      }

      transactions.sort((a, b) {
        final dateA =
        a['date'] as DateTime;

        final dateB =
        b['date'] as DateTime;

        return dateB.compareTo(dateA);
      });

      return {
        'year': targetYear,
        'month': targetMonth,

        'monthlyRevenue':
        monthlyRevenue,

        'currentMonthRevenue':
        currentMonthRevenue,

        'previousMonthRevenue':
        previousMonthRevenue,

        'evolution': evolution,

        'nightsCurrentMonth':
        nightsCurrentMonth,

        'totalYearRevenue':
        totalYearRevenue,

        'byApartment':
        byApartment,

        'transactions':
        transactions,
      };
    } catch (e, stackTrace) {
      debugPrint(
        'BackendService.getOwnerRevenueData: $e',
      );
      debugPrint('$stackTrace');

      return _emptyOwnerRevenueData(
        targetYear,
        targetMonth,
      );
    }
  }


  // DONNÉES PROTÉGÉES
  Future<dynamic> getProtectedData() async {
    try {
      final response = await supabase
          .from('protected_table')
          .select()
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des données protégées : $e',
      );
    }
  }


  // UTILITAIRES
  String _normalize(dynamic value) {
    return value
        ?.toString()
        .trim()
        .toLowerCase() ??
        '';
  }

  String _dateOnly(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return DateTime(
        value.year,
        value.month,
        value.day,
      );
    }

    final parsed =
    DateTime.tryParse(
      value.toString(),
    );

    if (parsed == null) {
      return null;
    }

    return DateTime(
      parsed.year,
      parsed.month,
      parsed.day,
    );
  }

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value
          .toString()
          .replaceAll(',', '.'),
    ) ??
        0;
  }

  List<String> _extractEquipements(
      dynamic value,
      ) {
    if (value is! Map) {
      return [];
    }

    final data =
    value['equipements'];

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (e) => e.toString(),
    )
        .toList();
  }

  Map<String, bool> _extractRegles(
      dynamic value,
      ) {
    if (value is! Map) {
      return {};
    }

    final data =
    value['regles_sejour'];

    if (data is! Map) {
      return {};
    }

    return data.map(
          (key, value) => MapEntry(
        key.toString(),
        value == true,
      ),
    );
  }


  //CALCUL REVENUS PÉRIODE
  double _calculateRevenueForPeriod(
      List<Map<String, dynamic>> reservations,
      DateTime periodStart,
      DateTime periodEnd,
      ) {
    double total = 0;

    for (final reservation
    in reservations) {
      final statut = _normalize(
        reservation['statut'],
      );

      if (statut != 'confirmee' &&
          statut != 'terminee') {
        continue;
      }

      final debut =
      _parseDate(
        reservation['date_debut'],
      );

      final fin =
      _parseDate(
        reservation['date_fin'],
      );

      if (debut == null || fin == null) {
        continue;
      }

      final prix = _toDouble(reservation['prix_proprietaire'],);

      final totalNuits = fin.difference(debut).inDays;

      if (prix <= 0 ||
          totalNuits <= 0) {
        continue;
      }

      final debutSejour = debut.isAfter(periodStart) ? debut : periodStart;

      final finSejour = fin.isBefore(periodEnd) ? fin : periodEnd;

      if (!debutSejour
          .isBefore(finSejour)) {
        continue;
      }

      final nuits = finSejour.difference(debutSejour).inDays;

      total += prix * nuits / totalNuits;
    }

    return total;
  }


  // DASHBOARD VIDE
  Map<String, dynamic>
  _emptyOwnerDashboardStats() {
    return {
      'revenus': 0.0,
      'revenus_mois_precedent': 0.0,
      'evolution_revenus': 0.0,

      'reservations': 0,
      'reservations_mois': 0,

      'taux_occupation': 0.0,

      'nuits_occupees': 0,
      'nuits_disponibles': 0,

      'note': 0.0,
      'avis': 0,

      'biens': 0,
      'villes': 0,

      'mois':
      DateTime.now().month,

      'annee':
      DateTime.now().year,
    };
  }


  // REVENUS VIDES
  Map<String, dynamic>
  _emptyOwnerRevenueData(
      int year,
      int month,
      ) {
    return {
      'year': year,
      'month': month,

      'monthlyRevenue':
      List<double>.filled(12, 0),

      'currentMonthRevenue': 0.0,
      'previousMonthRevenue': 0.0,

      'evolution': 0.0,

      'nightsCurrentMonth': 0,

      'totalYearRevenue': 0.0,

      'byApartment':
      <Map<String, dynamic>>[],

      'transactions':
      <Map<String, dynamic>>[],
    };
  }
}