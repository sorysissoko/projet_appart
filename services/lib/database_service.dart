import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'date_service.dart';

class DatabaseService {
  final SupabaseClient supabase;
  final SupabaseClient? _adminClient;

  DatabaseService({
    SupabaseClient? client,
    String? serviceUrl,
    String? serviceRoleKey,
  })  : supabase = client ?? Supabase.instance.client,
        _adminClient = (serviceUrl != null && serviceRoleKey != null)
            ? SupabaseClient(serviceUrl, serviceRoleKey)
            : null;

  // UTILISATEUR CONNECTÉ

  String? currentUserId() {
    return supabase.auth.currentUser?.id;
  }


  // VÉRIFICATION ANTI-DOUBLON RÉSIDENCE

  /// Vérifie si une résidence identique existe déjà pour ce propriétaire.
  ///
  /// Critères de doublon :
  /// - même propriétaire
  /// - même ville (insensible à la casse)
  /// - même adresse (insensible à la casse)
  /// - statut non supprimé
  Future<Map<String, dynamic>?> findExistingResidence({
    required String ville,
    required String adresse,
  }) async {
    final userId = currentUserId();

    if (userId == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      final response = await supabase
          .from('residences')
          .select('id, nom, ville, adresse, status, created_at')
          .eq('proprietaire_id', userId)
          .ilike('ville', ville.trim())
          .ilike('adresse', adresse.trim())
          .neq('status', 'supprimee')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return Map<String, dynamic>.from(response);
    } on PostgrestException catch (e) {
      debugPrint('findExistingResidence : ${e.message}');
      return null;
    }
  }


  Future<String> createResidence({
    String? nom,
    String? description,
    required String ville,
    required String adresse,
    String? localisation,
  }) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('Utilisateur non connecté.');
    }

    if (ville.trim().isEmpty) {
      throw Exception('La ville de la résidence est obligatoire.');
    }

    if (adresse.trim().isEmpty) {
      throw Exception('L’adresse de la résidence est obligatoire.');
    }

    final location = localisation?.trim();

    if (location != null && location.isNotEmpty) {
      final uri = Uri.tryParse(location);

      if (uri == null ||
          !uri.hasScheme ||
          (uri.scheme != 'http' && uri.scheme != 'https')) {
        throw Exception(
          'Le lien de localisation doit être une URL valide.',
        );
      }
    }

    // 🔴 ANTI-DOUBLON — VÉRIFICATION AVANT INSERTION
    final existing = await findExistingResidence(
      ville: ville,
      adresse: adresse,
    );

    if (existing != null) {
      final statut = existing['status']?.toString() ?? 'inconnu';
      throw Exception(
        'Une résidence à cette adresse existe déjà dans votre compte '
            '(statut : $statut).\n'
            'Si vous devez la remplacer, modifiez-la ou supprimez-la '
            'depuis vos résidences.',
      );
    }

    final data = <String, dynamic>{
      'proprietaire_id': userId,
      'nom': nom?.trim().isEmpty == true ? null : nom?.trim(),
      'description':
      description?.trim().isEmpty == true ? null : description?.trim(),
      'ville': ville.trim(),
      'adresse': adresse.trim(),
      'localisation':
      location == null || location.isEmpty ? null : location,
      'status': 'en_attente',
    };

    try {
      final result = await supabase
          .from('residences')
          .insert(data)
          .select('id')
          .single();

      return result['id'].toString();
    } on PostgrestException catch (e) {
      // Contrainte UNIQUE violée → doublon
      if (e.code == '23505') {
        throw Exception(
          'Cette résidence existe déjà. '
              'Modifiez ou supprimez l’ancienne avant d’en créer une nouvelle.',
        );
      }

      debugPrint('createResidence : ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Erreur createResidence: $e');
      rethrow;
    }
  }


  // ReSIDENCES DU PROPRIÉTAIRE

  Future<List<Map<String, dynamic>>> getMyResidences() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      final response = await supabase
          .from('residences')
          .select('''
          id,
          proprietaire_id,
          nom,
          description,
          ville,
          adresse,
          localisation,
          status,
          validated_by,
          validated_at,
          refusal_reason,
          created_at,
          updated_at
        ''')
          .eq('proprietaire_id', userId)
          .neq('status', 'supprimee')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      debugPrint('getMyResidences: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Erreur getMyResidences: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getResidenceById(
      String residenceId,
      ) async {
    if (residenceId.trim().isEmpty) {
      return null;
    }

    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      final response = await supabase
          .from('residences')
          .select('''
          id,
          proprietaire_id,
          nom,
          description,
          ville,
          adresse,
          localisation,
          status,
          validated_by,
          validated_at,
          refusal_reason,
          created_at,
          updated_at
        ''')
          .eq('id', residenceId)
          .eq('proprietaire_id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return Map<String, dynamic>.from(response);
    } on PostgrestException catch (e) {
      debugPrint('getResidenceById: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Erreur getResidenceById: $e');
      rethrow;
    }
  }


  // VÉRIFICATION ANTI-DOUBLON APPARTEMENT

  Future<Map<String, dynamic>?> findExistingAppartement({
    required String residenceId,
    required String titre,
  }) async {
    final userId = currentUserId();

    if (userId == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      final response = await supabase
          .from('appartements')
          .select('id, titre, status, created_at')
          .eq('proprietaire_id', userId)
          .eq('residence_id', residenceId.trim())
          .ilike('titre', titre.trim())
          .neq('status', 'supprime')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return Map<String, dynamic>.from(response);
    } on PostgrestException catch (e) {
      debugPrint('findExistingAppartement : ${e.message}');
      return null;
    }
  }

  // APPARTEMENTS

  Future<String> createAppartement({
    required String titre,
    required String type,
    required double prix,
    required String description,
    required String nbreSejour,
    required Map<String, dynamic> equipements,
    required String residenceId,
  }) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('Utilisateur non connecté.');
    }

    if (residenceId.trim().isEmpty) {
      throw Exception('La résidence est obligatoire.');
    }

    if (titre.trim().isEmpty) {
      throw Exception('Le titre de l’appartement est obligatoire.');
    }

    if (description.trim().isEmpty) {
      throw Exception('La description de l’appartement est obligatoire.');
    }

    if (type.trim().isEmpty) {
      throw Exception('Le type d’appartement est obligatoire.');
    }

    if (prix < 0) {
      throw Exception('Le prix ne peut pas être négatif.');
    }

    try {
      // 1. Vérification que la résidence appartient bien au propriétaire
      final residence = await supabase
          .from('residences')
          .select('id, proprietaire_id, status')
          .eq('id', residenceId)
          .eq('proprietaire_id', userId)
          .maybeSingle();

      if (residence == null) {
        throw Exception(
          'La résidence sélectionnée est introuvable '
              'ou ne vous appartient pas.',
        );
      }

      // 2. 🔴 ANTI-DOUBLON — VÉRIFICATION AVANT INSERTION
      final existing = await findExistingAppartement(
        residenceId: residenceId,
        titre: titre,
      );

      if (existing != null) {
        final statut = existing['status']?.toString() ?? 'inconnu';
        throw Exception(
          'Un appartement avec ce titre existe déjà dans cette résidence '
              '(statut : $statut).\n'
              'Modifiez ou supprimez l’ancien avant d’en créer un nouveau.',
        );
      }

      // 3. Insertion
      final data = <String, dynamic>{
        'proprietaire_id': userId,
        'residence_id': residenceId,
        'titre': titre.trim(),
        'type': type.trim(),
        'prix': prix,
        'description': description.trim(),
        'nbre_sejour': nbreSejour,
        'autres_equipements': equipements,
        'status': 'en_attente',
      };

      final result = await supabase
          .from('appartements')
          .insert(data)
          .select('id')
          .single();

      return result['id'].toString();
    } on PostgrestException catch (e) {
      // Contrainte UNIQUE violée → doublon (race condition)
      if (e.code == '23505') {
        throw Exception(
          'Cet appartement existe déjà dans cette résidence. '
              'Modifiez ou supprimez l’ancien avant d’en créer un nouveau.',
        );
      }

      debugPrint('createAppartement: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Erreur createAppartement: $e');
      rethrow;
    }
  }


  Future<void> updateAppartement({
    required String appartementId,
    String? residenceId,
    String? titre,
    String? description,
    num? prix,
    String? type,
    String? nbreSejour,
    Map<String, bool>? equipements,
  }) async {
    try {
      final updates = <String, dynamic>{
        // RÉSIDENCE

        if (residenceId != null &&
            residenceId.trim().isNotEmpty)
          'residence_id': residenceId.trim(),

        // INFORMATIONS APPARTEMENT

        if (titre != null)
          'titre': titre.trim(),

        if (description != null)
          'description': description.trim(),

        if (prix != null)
          'prix': prix,

        if (type != null)
          'type': type.trim(),

        if (nbreSejour != null)
          'nbre_sejour': nbreSejour,

        // ÉQUIPEMENTS

        if (equipements != null)
          'autres_equipements': equipements,

        // DATE DE MODIFICATION

        'updated_at':
        DateTime.now().toIso8601String(),
      };

      if (updates.isEmpty) {
        return;
      }

      await supabase
          .from('appartements')
          .update(updates)
          .eq('id', appartementId);
    } on PostgrestException catch (e) {
      debugPrint(
        'updateAppartement: ${e.message}',
      );

      throw Exception(e.message);
    } catch (e) {
      debugPrint(
        'Erreur updateAppartement: $e',
      );

      rethrow;
    }
  }

  Future<void> deleteAppartement(String appartementId) async {
    try {
      await supabase
          .from('appartements')
          .delete()
          .eq('id', appartementId);
    } on PostgrestException catch (e) {
      debugPrint('deleteAppartement: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Erreur deleteAppartement: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAppartements({
    int? limit,
    int? page,
  }) async {
    try {
      var query = supabase
          .from('appartements')
          .select('''
          *,
          residence:residences!appartements_residence_id_fkey (
            id,
            nom,
            ville,
            adresse,
            localisation,
            status
          )
        ''')
          .eq('status', 'publie')
          .order(
        'created_at',
        ascending: false,
      );

      if (limit != null && limit > 0) {
        final currentPage = page ?? 0;

        final start = currentPage * limit;
        final end = start + limit - 1;

        query = query.range(start, end);
      }

      final response = await query;

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      debugPrint(
        'fetchAppartements: ${e.message}',
      );
      debugPrint('code: ${e.code}');
      debugPrint('details: ${e.details}');
      debugPrint('hint: ${e.hint}');
      return [];
    } catch (e) {
      debugPrint(
        'Erreur fetchAppartements: $e',
      );
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchAppartementsEnAttente() async {
    try {
      final response = await supabase
          .from('appartements')
          .select('''
          *,
          residence:residences!appartements_residence_id_fkey (
            id,
            nom,
            ville,
            adresse,
            localisation,
            status
          )
        ''')
          .eq('status', 'en_attente')
          .order(
        'created_at',
        ascending: false,
      );

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      debugPrint(
        'fetchAppartementsEnAttente: ${e.message}',
      );
      debugPrint('code: ${e.code}');
      debugPrint('details: ${e.details}');
      debugPrint('hint: ${e.hint}');
      return [];
    } catch (e) {
      debugPrint(
        'Erreur fetchAppartementsEnAttente: $e',
      );
      return [];
    }
  }

// aPPARTEMENTS D'UNE RÉSIDENCE AVEC INFOS + STATUT OCCUPATION

  Future<List<Map<String, dynamic>>> fetchAppartementsWithInfos(
      String residenceId,
      ) async {
    try {
      final response = await supabase
          .from('appartements')
          .select('''
          id,
          residence_id,
          titre,
          type,
          prix,
          status,
          disponibilite_status,
          appartement_infos (
            etage,
            taille
          )
        ''')
          .eq('residence_id', residenceId)
          .order('titre', ascending: true);

      final list = List<Map<String, dynamic>>.from(response);

      // Aplatir les infos
      for (final item in list) {
        final infos = item['appartement_infos'];

        if (infos is List && infos.isNotEmpty) {
          item['etage'] = infos.first['etage'];
          item['taille'] = infos.first['taille'];
        } else if (infos is Map) {
          item['etage'] = infos['etage'];
          item['taille'] = infos['taille'];
        }
      }

      return list;
    } catch (e) {
      debugPrint('fetchAppartementsWithInfos: $e');
      return [];
    }
  }

// NOMBRE DE DOCS EN ATTENTE PAR RÉSIDENCE

  Future<Map<String, int>> fetchPendingDocsCountByResidence(
      List<String> residenceIds,
      ) async {
    if (residenceIds.isEmpty) return {};

    try {
      final response = await supabase
          .from('documents')
          .select('residence_id, statut')
          .inFilter('residence_id', residenceIds)
          .inFilter('statut', ['en_attente', 'en_verification']);

      final Map<String, int> counts = {};

      for (final doc in response) {
        final rid = doc['residence_id']?.toString();

        if (rid == null || rid.isEmpty) continue;

        counts[rid] = (counts[rid] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      debugPrint('fetchPendingDocsCountByResidence: $e');
      return {};
    }
  }

  Future<String> getProprietaireId(String appartementId) async {
    final response = await supabase
        .from('appartements')
        .select('proprietaire_id')
        .eq('id', appartementId)
        .single();

    return response['proprietaire_id'].toString();
  }

  // ADMIN: PUBLICATION / REFUS

  Future<void> publishAppartement(String appartementId) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Admin non connecté.');
    }

    try {
      final proprietaireId =
      await getProprietaireId(appartementId);

      await supabase
          .from('appartements')
          .update({
        'status': 'publie',
        'validated_by': user.id,
        'validated_at': DateTime.now().toIso8601String(),
        'refusal_reason': null,
      })
          .eq('id', appartementId);

      await supabase.from('notifications').insert({
        'user_id': proprietaireId,
        'message':
        'Votre appartement est maintenant publié et visible par les clients.',
      });

      debugPrint('Appartement publié : $appartementId');
    } on PostgrestException catch (e) {
      debugPrint('publishAppartement: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Erreur publishAppartement: $e');
      rethrow;
    }
  }

  Future<void> refuseAppartement(
      String appartementId,
      String motif,
      ) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Admin non connecté.');
    }

    if (motif.trim().isEmpty) {
      throw Exception('Le motif du refus est obligatoire.');
    }

    try {
      final proprietaireId =
      await getProprietaireId(appartementId);

      await supabase
          .from('appartements')
          .update({
        'status': 'refuse',
        'validated_by': user.id,
        'validated_at': DateTime.now().toIso8601String(),
        'refusal_reason': motif.trim(),
      })
          .eq('id', appartementId);

      await supabase.from('notifications').insert({
        'user_id': proprietaireId,
        'message':
        'Votre appartement a été refusé. Motif : ${motif.trim()}',
      });

      debugPrint('Appartement refusé : $appartementId');
    } on PostgrestException catch (e) {
      debugPrint('refuseAppartement: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Erreur refuseAppartement: $e');
      rethrow;
    }
  }

  // FAVORIS

  Future<bool> addToFavorites(String appartementId) async {
    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Utilisateur non connecté.');
      }

      final existing = await supabase
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('appartement_id', appartementId)
          .maybeSingle();

      if (existing != null) {
        return true;
      }

      await supabase.from('favorites').insert({
        'user_id': userId,
        'appartement_id': appartementId,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('addToFavorites: $e');
      return false;
    }
  }

  Future<bool> removeFromFavorites(String appartementId) async {
    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Utilisateur non connecté.');
      }

      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('appartement_id', appartementId);

      return true;
    } catch (e) {
      debugPrint('removeFromFavorites: $e');
      return false;
    }
  }

  Future<bool> isFavorite(String appartementId) async {
    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        return false;
      }

      final response = await supabase
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('appartement_id', appartementId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('isFavorite: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        return [];
      }

      final response = await supabase
          .from('favorites')
          .select('''
            *,
            appartement:appartement_id (*)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('getFavorites: $e');
      return [];
    }
  }

  // ÉQUIPEMENTS

  Future<Map<String, bool>> getEquipementsByAppartement(
      String appartementId,
      ) async {
    try {
      final response = await supabase
          .from('appartements')
          .select('autres_equipements')
          .eq('id', appartementId)
          .maybeSingle();

      if (response == null ||
          response['autres_equipements'] == null) {
        return {};
      }

      final raw = response['autres_equipements'];

      if (raw is! Map) {
        return {};
      }

      final result = <String, bool>{};

      for (final entry in raw.entries) {
        result[entry.key.toString()] = entry.value == true;
      }

      return result;
    } catch (e) {
      debugPrint(
        'getEquipementsByAppartement: $e',
      );
      return {};
    }
  }

  Future<void> updateEquipements({
    required String appartementId,
    required Map<String, bool> equipements,
  }) async {
    try {
      await supabase
          .from('appartements')
          .update({
        'autres_equipements': equipements,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', appartementId);
    } catch (e) {
      debugPrint('updateEquipements: $e');
      rethrow;
    }
  }

  Future<bool> getEquipementValue({
    required String appartementId,
    required String key,
  }) async {
    final equipements =
    await getEquipementsByAppartement(appartementId);

    return equipements[key] ?? false;
  }

  Future<void> updateEquipement({
    required String appartementId,
    required String key,
    required bool value,
  }) async {
    final equipements =
    await getEquipementsByAppartement(appartementId);

    equipements[key] = value;

    await updateEquipements(
      appartementId: appartementId,
      equipements: equipements,
    );
  }

  // PHOTOS

  Future<List<Map<String, dynamic>>> fetchPhotos(
      String appartementId,
      ) async {
    try {
      final response = await supabase
          .from('photo_appartements')
          .select()
          .eq('appartement_id', appartementId)
          .order('est_principale', ascending: false)
          .order('ordre_affichage', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('fetchPhotos: $e');
      return [];
    }
  }

  Future<void> resetPhotoPrincipale(
      String appartementId,
      ) async {
    await supabase
        .from('photo_appartements')
        .update({
      'est_principale': false,
    })
        .eq('appartement_id', appartementId);
  }

  Future<Map<String, dynamic>?> uploadPhotoSafe({
    required String appartementId,
    required Uint8List bytes,
    bool estPrincipale = false,
    String? titre,
    int ordreAffichage = 0,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final path = '$appartementId/$fileName';

    try {
      // Si la photo doit devenir principale, toutes les anciennes principales sont désactivées.
      if (estPrincipale) {
        await resetPhotoPrincipale(appartementId);
      }

      // Upload Storage
      await supabase.storage
          .from('appartements')
          .uploadBinary(
        path,
        bytes,
      );

      try {
        // Insertion DB
        final data = await supabase
            .from('photo_appartements')
            .insert({
          'appartement_id': appartementId,
          'fichiername': fileName,
          'extension': 'jpg',
          'est_principale': estPrincipale,
          'ordre_affichage': ordreAffichage,
          'titre': titre,
        })
            .select()
            .single();

        return Map<String, dynamic>.from(data);
      } catch (e) {
        // Si insertion DB échoue, on essaie de supprimer le fichier Storage.
        try {
          await supabase.storage
              .from('appartements')
              .remove([path]);
        } catch (_) {}

        rethrow;
      }
    } catch (e) {
      debugPrint('uploadPhotoSafe: $e');
      rethrow;
    }
  }

  Future<void> deletePhoto(String photoId) async {
    try {
      final photo = await supabase
          .from('photo_appartements')
          .select(
        'appartement_id, fichiername',
      )
          .eq('id', photoId)
          .maybeSingle();

      if (photo == null) {
        return;
      }

      final appartementId =
      photo['appartement_id']?.toString();

      final fileName =
      photo['fichiername']?.toString();

      // Suppression Storage
      if (appartementId != null &&
          appartementId.isNotEmpty &&
          fileName != null &&
          fileName.isNotEmpty) {
        try {
          await supabase.storage
              .from('appartements')
              .remove([
            '$appartementId/$fileName',
          ]);
        } catch (e) {
          debugPrint(
            'Suppression Storage échouée: $e',
          );
        }
      }

      // Suppression DB
      await supabase
          .from('photo_appartements')
          .delete()
          .eq('id', photoId);
    } catch (e) {
      debugPrint('deletePhoto: $e');
      rethrow;
    }
  }

  String photoUrl(
      String appartementId,
      String fileName,
      ) {
    return supabase.storage
        .from('appartements')
        .getPublicUrl(
      '$appartementId/$fileName',
    );
  }

  Future<List<String>> loadPhotoUrls(
      String appartementId,
      ) async {
    try {
      final photos =
      await fetchPhotos(appartementId);

      final urls = <String>[];

      for (final photo in photos) {
        final fileName =
        photo['fichiername']?.toString();

        if (fileName != null &&
            fileName.isNotEmpty) {
          urls.add(
            photoUrl(
              appartementId,
              fileName,
            ),
          );
        }
      }

      return urls;
    } catch (e) {
      debugPrint('loadPhotoUrls: $e');
      return [];
    }
  }

  // APPARTEMENT RÔLE

  Future<void> insertAppartementRole({
    required String appartementId,
    required String description,
    required TimeOfDay heureArrive,
    required TimeOfDay heureDepart,
    required int nombreClient,
    required String fete,
    required String animaux,
    required String fumeur,
  }) async {
    if (appartementId.trim().isEmpty) {
      throw Exception('ID appartement invalide.');
    }

    if (description.trim().isEmpty) {
      throw Exception('La description des règles est obligatoire.');
    }

    if (nombreClient < 1) {
      throw Exception(
        'Le nombre de clients doit être supérieur ou égal à 1.',
      );
    }

    final data = {
      'appartement_id': appartementId,
      'description': description.trim(),
      'heure_arrive':
      '${heureArrive.hour.toString().padLeft(2, '0')}:'
          '${heureArrive.minute.toString().padLeft(2, '0')}',
      'heure_depart':
      '${heureDepart.hour.toString().padLeft(2, '0')}:'
          '${heureDepart.minute.toString().padLeft(2, '0')}',
      'nombre_client': nombreClient,
      'fete': fete,
      'animaux': animaux,
      'fumeur': fumeur,
    };

    await supabase
        .from('appartement_role')
        .insert(data);
  }
  Future<List<Map<String, dynamic>>> getRolesByAppartement(
      String appartementId,
      ) async {
    try {
      final response = await supabase
          .from('appartement_role')
          .select()
          .eq('appartement_id', appartementId)
          .order(
        'created_at',
        ascending: false,
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('getRolesByAppartement: $e');
      return [];
    }
  }

  Future<void> updateAppartementRole({
    required String roleId,
    required String description,
    required TimeOfDay heureArrive,
    required TimeOfDay heureDepart,
    required int nombreClient,
    required String fete,
    required String animaux,
    required String fumeur,
  }) async {
    try {
      if (nombreClient < 1) {
        throw Exception(
          'Le nombre de clients doit être supérieur ou égal à 1.',
        );
      }

      await supabase
          .from('appartement_role')
          .update({
        'description': description.trim(),
        'heure_arrive':
        '${heureArrive.hour.toString().padLeft(2, '0')}:'
            '${heureArrive.minute.toString().padLeft(2, '0')}',
        'heure_depart':
        '${heureDepart.hour.toString().padLeft(2, '0')}:'
            '${heureDepart.minute.toString().padLeft(2, '0')}',
        'nombre_client': nombreClient,
        'fete': _normalizeFeteValue(fete),
        'animaux': _normalizeAnimauxValue(animaux),
        'fumeur': _normalizeFumeurValue(fumeur),
        'updated_at':
        DateTime.now().toIso8601String(),
      })
          .eq('id', roleId);
    } catch (e) {
      debugPrint('updateAppartementRole: $e');
      rethrow;
    }
  }

  String _normalizeFeteValue(String value) {
    if (value.trim().isEmpty) {
      return 'Pas de fêtes';
    }

    final lower =
    value.trim().toLowerCase();

    if (lower.contains('accept') ||
        lower.contains('fetes acceptees') ||
        lower.contains('fêtes acceptées') ||
        lower == 'oui') {
      return 'Fêtes acceptées';
    }

    return 'Pas de fêtes';
  }

  String _normalizeAnimauxValue(String value) {
    if (value.trim().isEmpty) {
      return 'Pas d animaux';
    }

    final lower =
    value.trim().toLowerCase();

    if (lower.contains('chien')) {
      return 'Animaux acceptés: Chien';
    }

    if (lower.contains('chat')) {
      return 'Animaux acceptés: Chat';
    }

    if (lower.contains('accept') ||
        lower == 'oui') {
      return 'Animaux acceptés: Chien';
    }

    return 'Pas d animaux';
  }

  String _normalizeFumeurValue(String value) {
    if (value.trim().isEmpty) {
      return 'Fumeurs non acceptés';
    }

    final lower =
    value.trim().toLowerCase();

    if (lower.contains('fumeurs acceptés') ||
        lower.contains('fumeurs acceptes')) {
      return 'Fumeurs acceptés';
    }

    if (lower == 'oui' ||
        lower == 'acceptés' ||
        lower == 'acceptes') {
      return 'Fumeurs acceptés';
    }

    return 'Fumeurs non acceptés';
  }

  Future<void> deleteAppartementRole(
      String roleId,
      ) async {
    await supabase
        .from('appartement_role')
        .delete()
        .eq('id', roleId);
  }


  // APPARTEMENT INFORMATIONS

  Future<String> insertAppartementInfo({
    required String appartementId,
    required int chambre,
    required int salon,
    required int douche,
    required int cuisine,
    required int etage,
    required double taille,
    String serviceInclus = 'Non',
    String internet = 'Non',
    String stationnement = 'Non',
    String meuble = 'Non',
    String climatisation = 'Non',
  }) async {
    try {
      final response = await supabase
          .from('appartement_infos')
          .insert({
        'appartement_id': appartementId,
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
      })
          .select('id')
          .single();

      return response['id'].toString();
    } catch (e) {
      debugPrint('insertAppartementInfo: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getInfoByAppartement(
      String appartementId,
      ) async {
    try {
      final response = await supabase
          .from('appartement_infos')
          .select()
          .eq('appartement_id', appartementId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('getInfoByAppartement: $e');
      return [];
    }
  }

  Future<void> updateAppartementInfo({
    required String infoId,
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
    try {
      await supabase
          .from('appartement_infos')
          .update({
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
      })
          .eq('id', infoId);
    } catch (e) {
      debugPrint('updateAppartementInfo: $e');
      rethrow;
    }
  }

  Future<void> deleteAppartementInfo(
      String infoId,
      ) async {
    await supabase
        .from('appartement_infos')
        .delete()
        .eq('id', infoId);
  }

  // RÉSERVATIONS

  /// Vérification si une période est disponible.
  /// Les statuts bloquants : - en_attente, - en_attente_paiement, - confirmee
  /// Les intervalles sont considérés comme : [date_debut, date_fin)
  /// Donc le jour du départ peut être réutilisé
  /// comme jour d'arrivée d'une autre réservation.
  Future<bool> isDateRangeAvailable({
    required String appartementId,
    required DateTime startDate,
    required DateTime endDate,
    String? excludeReservationId,
  }) async {
    try {
      final start = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );

      final end = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
      );

      if (!start.isBefore(end)) {
        return false;
      }

      var query = supabase
          .from('reservations')
          .select(
        'id, date_debut, date_fin, statut',
      )
          .eq(
        'appartement_id',
        appartementId,
      )
          .filter(
        'statut',
        'in',
        '("en_attente","en_attente_paiement","confirmee")',
      );

      if (excludeReservationId != null &&
          excludeReservationId.trim().isNotEmpty) {
        query = query.neq(
          'id',
          excludeReservationId,
        );
      }

      final reservations = await query;

      for (final reservation in reservations) {
        final existingStart = DateTime.parse(
          reservation['date_debut'].toString(),
        );

        final existingEnd = DateTime.parse(
          reservation['date_fin'].toString(),
        );

        final overlap =
            start.isBefore(existingEnd) &&
                end.isAfter(existingStart);

        if (overlap) {
          debugPrint(
            'Conflit réservation ${reservation['id']}',
          );
          return false;
        }
      }

      return true;
    } on PostgrestException catch (e) {
      debugPrint(
        'isDateRangeAvailable: ${e.message}',
      );
      return false;
    } catch (e) {
      debugPrint(
        'Erreur isDateRangeAvailable: $e',
      );
      return false;
    }
  }

  //Récupère les périodes réservées.
  Future<List<DateTimeRange>> getReservedDateRanges({
    required String appartementId,
  }) async {
    try {
      final reservations = await supabase
          .from('reservations')
          .select(
        'date_debut, date_fin, statut',
      )
          .eq(
        'appartement_id',
        appartementId,
      )
          .filter(
        'statut',
        'in',
        '("en_attente","en_attente_paiement","confirmee")',
      )
          .order(
        'date_debut',
        ascending: true,
      );

      return reservations.map<DateTimeRange>((reservation) {
        return DateTimeRange(
          start: DateTime.parse(
            reservation['date_debut'].toString(),
          ),
          end: DateTime.parse(
            reservation['date_fin'].toString(),
          ),
        );
      }).toList();
    } catch (e) {
      debugPrint(
        'getReservedDateRanges: $e',
      );
      return [];
    }
  }


  // CRÉER UNE RÉSERVATION
  Future<String> createReservation({
    required String appartementId,
    required String dateDebut,
    required String dateFin,
    required String momentPaiement,
    required String methodePaiement,
    String? message,
    int adultes = 1,
    int enfants = 0,

    // Paiement mobile
    String? telephonePaiement,
    String? indicatifPaiement,

    // Carte bancaire
    String? providerPaymentMethodId,

    // Informations prestataire
    String? provider,
    String? cardBrand,
    String? cardLast4,
  }) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Utilisateur non connecté.');
      }

      // MODE DE PAIEMENT
      final howToPay = momentPaiement.trim();

      if (howToPay != 'totalite' && howToPay != 'acompte') {
        throw Exception(
          'Le mode de paiement sélectionné est invalide.',
        );
      }

      // MOYEN DE PAIEMENT
      final methode = methodePaiement.trim();

      const methodesAutorisees = {
        'orange_money',
        'moov_money',
        'wave',
        'carte_bancaire',
      };

      if (!methodesAutorisees.contains(methode)) {
        throw Exception(
          'Veuillez sélectionner un moyen de paiement valide.',
        );
      }

      // VOYAGEURS
      if (adultes < 1) {
        throw Exception(
          'Le nombre d\'adultes doit être supérieur ou égal à 1.',
        );
      }

      if (enfants < 0) {
        throw Exception(
          'Le nombre d\'enfants ne peut pas être négatif.',
        );
      }

      // VALIDATION PAIEMENT MOBILE
      if (methode == 'orange_money' ||
          methode == 'moov_money' ||
          methode == 'wave') {
        if (telephonePaiement == null ||
            telephonePaiement.trim().isEmpty) {
          throw Exception(
            'Le numéro de téléphone de paiement est obligatoire.',
          );
        }
      }

      // VALIDATION CARTE
      if (methode == 'carte_bancaire') {
        if (providerPaymentMethodId == null ||
            providerPaymentMethodId.trim().isEmpty) {
          throw Exception(
            'L\'identifiant sécurisé du moyen de paiement est obligatoire.',
          );
        }
      }

      // RPC
      final response = await supabase.rpc(
        'create_reservation',
        params: {
          'p_appartement_id': appartementId,
          'p_date_debut': dateDebut,
          'p_date_fin': dateFin,
          'p_how_to_pay': howToPay,
          'p_methode_paiement': methode,
          'p_adulte': adultes,
          'p_enfant': enfants,
          'p_message': message,

          // Paiement mobile
          'p_telephone_paiement': telephonePaiement,
          'p_indicatif_paiement': indicatifPaiement,

          // Carte bancaire
          'p_provider_payment_method_id': providerPaymentMethodId,

          // Prestataire
          'p_provider': provider,
          'p_card_brand': cardBrand,
          'p_card_last4': cardLast4,
        },
      );

      if (response == null) {
        throw Exception(
          'La réservation n\'a pas pu être créée.',
        );
      }

      unawaited(marquerReservationsTerminees());

      // UUID DIRECT
      if (response is String) {
        debugPrint('Réservation créée : $response');
        return response;
      }

      // JSON
      if (response is Map) {
        final reservationId =
            response['reservation_id'] ?? response['id'];

        if (reservationId == null) {
          throw Exception(
            'Le serveur n\'a pas retourné '
                'l\'identifiant de la réservation.',
          );
        }

        debugPrint('Réservation créée : $reservationId');
        return reservationId.toString();
      }

      throw Exception(
        'Réponse inattendue du serveur lors '
            'de la création de la réservation.',
      );
    } on PostgrestException catch (e) {
      debugPrint('PostgreSQL create_reservation');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('createReservation: $e');
      rethrow;
    }
  }

  // RÉSERVATIONS EN ATTENTE PROPRIÉTAIRE
  Future<List<Map<String, dynamic>>>
  getPendingReservationsForOwner() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        return [];
      }

      final appartements = await supabase
          .from('appartements')
          .select('id')
          .eq(
        'proprietaire_id',
        user.id,
      );

      if (appartements.isEmpty) {
        return [];
      }

      final appartementIds = appartements
          .map(
            (item) => item['id'].toString(),
      )
          .toList();

      final data = await supabase
          .from('reservations')
          .select('''
            *,
            appartement:appartements!reservations_appartement_id_fkey (
                *,
                residence:residences!appartements_residence_id_fkey (
                  id,
                  nom,
                  ville,
                  adresse,
                  localisation,
                  status
                )
              ),
              
              locataire:users!reservations_locataire_id_fkey (
                nom,
                prenom,
                email,
                telephone
              )
          ''')
          .inFilter(
        'appartement_id',
        appartementIds,
      )
          .eq(
        'statut',
        'en_attente',
      )
          .order(
        'created_at',
        ascending: false,
      );

      debugPrint(
        'Réservations en attente : ${data.length}',
      );

      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (e) {
      debugPrint(
        'getPendingReservationsForOwner: ${e.message}',
      );
      return [];
    } catch (e) {
      debugPrint(
        'Erreur getPendingReservationsForOwner: $e',
      );
      return [];
    }
  }


  // DÉCISION PROPRIÉTAIRE
  Future<Map<String, dynamic>>
  ownerDecideReservation({
    required String reservationId,
    required bool accept,
  }) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception(
          'Utilisateur non connecté.',
        );
      }

      final response = await supabase.rpc(
        'owner_decide_reservation',
        params: {
          'p_reservation_id': reservationId,
          'p_accept': accept,
        },
      );

      if (response == null) {
        throw Exception(
          'La décision de réservation '
              'n’a pas pu être traitée.',
        );
      }

      if (response is! Map) {
        throw Exception(
          'Réponse inattendue du serveur.',
        );
      }

      final result =
      Map<String, dynamic>.from(response);

      debugPrint(
        'Décision réservation : '
            '${result['statut']}',
      );

      return result;
    } on PostgrestException catch (e) {
      debugPrint(
        'owner_decide_reservation',
      );

      throw Exception(e.message);
    } catch (e) {
      debugPrint(
        'ownerDecideReservation: $e',
      );
      rethrow;
    }
  }

  // ADMIN et pROPRIÉTAIRE CONFIRMER UNE RÉSERVATION

  Future<Map<String, dynamic>> confirmerReservation(
      String reservationId,
      ) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception(
          'Utilisateur non connecté.',
        );
      }

      final response = await supabase.rpc(
        'confirmer_reservation',
        params: {
          'p_reservation_id': reservationId,
        },
      );

      if (response == null) {
        throw Exception(
          'La confirmation de la réservation '
              'n’a pas pu être traitée.',
        );
      }

      if (response is! Map) {
        throw Exception(
          'Réponse inattendue du serveur.',
        );
      }

      final result = Map<String, dynamic>.from(response);

      return result;
    } on PostgrestException catch (e) {
      debugPrint(
        'confirmer_reservation',
      );

      throw Exception(e.message);
    } catch (e) {
      debugPrint(
        'confirmerReservation: $e',
      );
      rethrow;
    }
  }


  Future<int> marquerReservationsTerminees() async {
    try {
      final response = await supabase.rpc(
        'marquer_reservations_terminees',
      );

      final count = (response is int)
          ? response
          : int.tryParse(response?.toString() ?? '0') ?? 0;

      if (count > 0) {
        debugPrint(
          '$count réservation(s) passée(s) en terminée',
        );
      }

      return count;
    } catch (e) {
      debugPrint(
        'Erreur marquage réservations terminées : $e',
      );
      return 0;
    }
  }

  Future<Map<String, dynamic>> refuserReservation(
      String reservationId,
      ) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Utilisateur non connecté.');
      }

      final response = await supabase.rpc(
        'refuser_reservation',
        params: {
          'p_reservation_id': reservationId,
        },
      );

      if (response == null) {
        throw Exception(
          'Le refus de la réservation a échoué.',
        );
      }

      if (response is! Map) {
        throw Exception(
          'Réponse inattendue du serveur.',
        );
      }

      final result = Map<String, dynamic>.from(response);


      return result;
    } on PostgrestException catch (e) {
      debugPrint('refuser_reservation');

      throw Exception(e.message);
    } catch (e) {
      debugPrint('refuserReservation: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> supprimerReservation(
      String reservationId,
      ) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Utilisateur non connecté.');
      }

      final response = await supabase.rpc(
        'supprimer_reservation',
        params: {
          'p_reservation_id': reservationId,
        },
      );

      if (response == null) {
        throw Exception(
          'La suppression de la réservation a échoué.',
        );
      }

      if (response is! Map) {
        throw Exception(
          'Réponse inattendue du serveur.',
        );
      }

      final result = Map<String, dynamic>.from(response);

      return result;
    } on PostgrestException catch (e) {
      debugPrint('supprimer_reservation');

      throw Exception(e.message);
    } catch (e) {
      debugPrint(
        'supprimerReservation: $e',
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> modifierDatesReservation({
    required String reservationId,
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Utilisateur non connecté.');
      }

      final response = await supabase.rpc(
        'modifier_dates_reservation',
        params: {
          'p_reservation_id': reservationId,
          'p_date_debut':
          dateDebut.toIso8601String().split('T').first,
          'p_date_fin':
          dateFin.toIso8601String().split('T').first,
        },
      );

      if (response == null) {
        throw Exception(
          'La modification des dates a échoué.',
        );
      }

      if (response is! Map) {
        throw Exception(
          'Réponse inattendue du serveur.',
        );
      }

      final result = Map<String, dynamic>.from(response);

      return result;
    } on PostgrestException catch (e) {

      throw Exception(e.message);
    } catch (e) {
      debugPrint(
        'modifierDatesReservation: $e',
      );
      rethrow;
    }
  }


  //notattion d'un appartement
  Future<bool> peutNoterAppartement(String appartementId) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        debugPrint('Utilisateur non connecté');
        return false;
      }

      final response = await supabase.rpc(
        'peut_noter_appartement',
        params: {
          'p_appartement_id': appartementId,
          'p_user_id': user.id,
        },
      );

      final peutNoter = response == true;

      debugPrint(
        'peutNoterAppartement($appartementId) = $peutNoter',
      );

      return peutNoter;
    } catch (e) {
      debugPrint('Erreur peutNoterAppartement : $e');
      return false;
    }
  }

  // DÉTAILS RÉSERVATION

  Future<Map<String, dynamic>?>
  getReservationDetails(
      String reservationId,
      ) async {
    try {
      final data = await supabase
          .from('reservations')
          .select('''
            *,
            appartement:appartements!reservations_appartement_id_fkey (
            *,
            residence:residences!appartements_residence_id_fkey (
              id,
              nom,
              ville,
              adresse,
              localisation,
              status
            )
          ),
          
          locataire:users!reservations_locataire_id_fkey (
            nom,
            prenom,
            email,
            telephone
          )
          ''')
          .eq(
        'id',
        reservationId,
      )
          .single();

      return Map<String, dynamic>.from(data);
    } on PostgrestException catch (e) {
      debugPrint(
        'getReservationDetails: ${e.message}',
      );
      return null;
    } catch (e) {
      debugPrint(
        'Erreur getReservationDetails: $e',
      );
      return null;
    }
  }


  // RÉSERVATIONS D'UN APPARTEMENT

  Future<List<Map<String, dynamic>>>
  getReservationsByAppartement(
      String appartementId,
      ) async {
    try {
      final response = await supabase
          .from('reservations')
          .select('''
            id,
            appartement_id,
            locataire_id,
            proprietaire_id,
            date_debut,
            date_fin,
            how_to_pay,
            methode_paiement,
            acompte,
            prix_total,
            prix_proprietaire,
            frais_service,
            reduction,
            adulte,
            enfant,
            statut,
            message,
            motif_refus,
            created_at,
            updated_at
          ''')
          .eq(
        'appartement_id',
        appartementId,
      )
          .order(
        'date_debut',
        ascending: true,
      );

      return List<Map<String, dynamic>>.from(
        response,
      );
    } on PostgrestException catch (e) {
      debugPrint(
        'getReservationsByAppartement: '
            '${e.message}',
      );
      return [];
    } catch (e) {
      debugPrint(
        'Erreur getReservationsByAppartement: $e',
      );
      return [];
    }
  }


  // ANNULER UNE RÉSERVATION

  Future<void> cancelReservation(
      String reservationId,
      ) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception(
          'Utilisateur non connecté.',
        );
      }

      await supabase.rpc(
        'cancel_reservation',
        params: {
          'p_reservation_id': reservationId,
        },
      );

      debugPrint(
        'Réservation annulée : $reservationId',
      );
    } on PostgrestException catch (e) {
      debugPrint(
        'cancel_reservation',
      );

      throw Exception(e.message);
    } catch (e) {
      debugPrint(
        'cancelReservation: $e',
      );
      rethrow;
    }
  }


  // ANCIENNES MÉTHODES RÉSERVATION
  @Deprecated(
    'Utilisez un RPC sécurisé dédié.',
  )
  Future<void> updateReservationDates({
    required String reservationId,
    required String dateDebut,
    required String dateFin,
    required int nuits,
  }) async {
    throw UnsupportedError(
      'La modification directe des dates est désactivée.',
    );
  }

  @Deprecated(
    'Utilisez les RPC sécurisés du workflow réservation.',
  )
  Future<void> updateReservationStatus(
      String reservationId,
      String statut,
      ) async {
    throw UnsupportedError(
      'La modification directe du statut est désactivée.',
    );
  }

  @Deprecated(
    'Utilisez cancelReservation().',
  )
  Future<void> deleteReservation(
      String reservationId,
      ) async {
    throw UnsupportedError(
      'La suppression directe d’une réservation est désactivée. '
          'Utilisez cancelReservation().',
    );
  }

  // RÉSERVATIONS DU LOCATAIRE

  Future<List<Map<String, dynamic>>>
  getReservationsForClient() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        return [];
      }

      final data = await supabase
          .from('reservations')
          .select('''
          *,
          appartement:appartements!reservations_appartement_id_fkey (
            id,
            titre,
            prix,
            type,
            nbre_sejour,
            created_at,
            status,
          
            residence:residences!appartements_residence_id_fkey (
              id,
              nom,
              ville,
              adresse,
              localisation
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

      debugPrint(
        'Réservations trouvées : ${data.length}',
      );

      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (e) {
      debugPrint(
        'getReservationsForClient: ${e.message}',
      );
      return [];
    } catch (e) {
      debugPrint(
        'Erreur getReservationsForClient: $e',
      );
      return [];
    }
  }

  // COUPONS

  Future<void> createCouponAsAdmin({
    required String code,
    required num reduction,
    required DateTime dateExpiration,
  }) async {
    if (_adminClient == null) {
      throw Exception(
        'Admin client non configuré.',
      );
    }

    await _adminClient.from('coupons').insert({
      'code': code.trim(),
      'reduction': reduction,
      'date_expiration':
      dateExpiration.toIso8601String(),
      'actif': true,
      'created_at':
      DateTime.now().toIso8601String(),
    });
  }

  Future<void> toggleCouponActiveAsAdmin(
      String couponId,
      bool actif,
      ) async {
    if (_adminClient == null) {
      throw Exception(
        'Admin client non configuré.',
      );
    }

    await _adminClient
        .from('coupons')
        .update({
      'actif': actif,
      'updated_at':
      DateTime.now().toIso8601String(),
    })
        .eq('id', couponId);
  }

  Future<List<Map<String, dynamic>>>
  listActiveCoupons() async {
    try {
      final response = await supabase
          .from('coupons')
          .select()
          .eq('actif', true);

      return List<Map<String, dynamic>>.from(
        response,
      );
    } catch (e) {
      debugPrint(
        'listActiveCoupons: $e',
      );
      return [];
    }
  }


  // DASHBOARD

  Future<List<Map<String, dynamic>>>
  fetchAppartementsForDashboard({
    required List<String> villes,
    required List<String> types,
  }) async {
    try {
      if (villes.isEmpty || types.isEmpty) {
        return [];
      }

      final response = await supabase
          .from('appartements')
          .select('''
          *,
          residence:residences!appartements_residence_id_fkey (
            id,
            nom,
            ville,
            adresse,
            localisation,
            status
          )
        ''')
          .eq('status', 'publie')
          .inFilter('residence.ville', villes)
          .inFilter('type', types);

      return List<Map<String, dynamic>>.from(
        response,
      );
    } catch (e) {
      debugPrint(
        'fetchAppartementsForDashboard: $e',
      );
      return [];
    }
  }

  Future<List<Map<String, dynamic>>>
  fetchPhotosByAppartementIds(
      List<String> appartementIds,
      ) async {
    if (appartementIds.isEmpty) {
      return [];
    }

    try {
      final response = await supabase
          .from('photo_appartements')
          .select()
          .inFilter(
        'appartement_id',
        appartementIds,
      );

      return List<Map<String, dynamic>>.from(
        response,
      );
    } catch (e) {
      debugPrint(
        'fetchPhotosByAppartementIds: $e',
      );
      return [];
    }
  }


  // DISPONIBILITÉS

  Future<Map<String, DateTime?>?>
  fetchNextDisponibilite(
      String appartementId,
      ) async {
    try {
      final today = DateService.formatToDb(
        DateTime.now(),
      );

      final data = await supabase
          .from('disponibilites')
          .select(
        'date_debut, date_fin',
      )
          .eq(
        'appartement_id',
        appartementId,
      )
          .gte(
        'date_fin',
        today,
      )
          .order(
        'date_debut',
        ascending: true,
      )
          .limit(1)
          .maybeSingle();

      if (data == null) {
        return null;
      }

      return {
        'date_debut': DateTime.parse(
          data['date_debut'].toString(),
        ),
        'date_fin': DateTime.parse(
          data['date_fin'].toString(),
        ),
      };
    } catch (e) {
      debugPrint(
        'fetchNextDisponibilite: $e',
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?>
  fetchDisponibiliteByAppartementId(
      String appartementId,
      ) async {
    try {
      final response = await supabase
          .from('disponibilites')
          .select()
          .eq(
        'appartement_id',
        appartementId,
      )
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return Map<String, dynamic>.from(
        response,
      );
    } catch (e) {
      debugPrint(
        'fetchDisponibiliteByAppartementId: $e',
      );
      return null;
    }
  }

  Future<void> createDisponibilites({
    required String appartementId,
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    final start = DateTime(
      dateDebut.year,
      dateDebut.month,
      dateDebut.day,
    );

    final end = DateTime(
      dateFin.year,
      dateFin.month,
      dateFin.day,
    );

    if (end.isBefore(start)) {
      throw Exception(
        'La date de fin ne peut pas être avant '
            'la date de début.',
      );
    }

    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'Aucun utilisateur connecté.',
      );
    }

    try {
      await supabase.from('disponibilites').insert({
        'appartement_id': appartementId,
        'proprietaire_id': user.id,
        'date_debut':
        DateService.formatToDb(start),
        'date_fin':
        DateService.formatToDb(end),
        'created_at':
        DateTime.now().toIso8601String(),
      });

      debugPrint(
        'Disponibilité créée.',
      );
    } catch (e) {
      debugPrint(
        'createDisponibilites: $e',
      );
      rethrow;
    }
  }

  Future<void> updateDisponibilite({
    required String disponibiliteId,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    try {
      final updates = <String, dynamic>{
        if (dateDebut != null)
          'date_debut':
          DateService.formatToDb(
            dateDebut,
          ),
        if (dateFin != null)
          'date_fin':
          DateService.formatToDb(
            dateFin,
          ),
        'updated_at':
        DateTime.now().toIso8601String(),
      };

      await supabase
          .from('disponibilites')
          .update(updates)
          .eq('id', disponibiliteId);
    } catch (e) {
      debugPrint(
        'updateDisponibilite: $e',
      );
      rethrow;
    }
  }

  Future<void> deleteDisponibilite(
      String disponibiliteId,
      ) async {
    try {
      await supabase
          .from('disponibilites')
          .delete()
          .eq('id', disponibiliteId);
    } catch (e) {
      debugPrint(
        'deleteDisponibilite: $e',
      );
      rethrow;
    }
  }


  // DISPONIBILITÉ ACTUELLE (BATCH)
  Future<Map<String, bool>> fetchDisponibiliteActuelleBatch(
      List<String> appartementIds,
      ) async {
    if (appartementIds.isEmpty) return {};

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    debugPrint('🔍 fetchDisponibiliteActuelleBatch : ${appartementIds.length} apps');
    debugPrint('🔍 Today = $today');

    try {

      //DISPONIBILITÉS
      final disposResponse = await supabase
          .from('disponibilites')
          .select('appartement_id, date_debut, date_fin')
          .inFilter('appartement_id', appartementIds);

      debugPrint('disponibilités trouvées : ${disposResponse.length}');
      debugPrint('détail : $disposResponse');

      final Map<String, List<Map<String, dynamic>>> disposByApp = {};

      for (final row in disposResponse) {
        final appId = row['appartement_id']?.toString();
        if (appId == null || appId.isEmpty) continue;

        disposByApp.putIfAbsent(appId, () => []).add({
          'date_debut': row['date_debut'],
          'date_fin': row['date_fin'],
        });
      }

      debugPrint('disposByApp : $disposByApp');

      //RÉSERVATIONS BLOQUANTES
      final reservationsResponse = await supabase
          .from('reservations')
          .select('appartement_id, date_debut, date_fin, statut')
          .inFilter('appartement_id', appartementIds)
          .filter(
        'statut',
        'in',
        '("en_attente","en_attente_paiement","confirmee")',
      );

      debugPrint('réservations bloquantes : ${reservationsResponse.length}');

      final Map<String, List<Map<String, dynamic>>> reservationsByApp = {};

      for (final row in reservationsResponse) {
        final appId = row['appartement_id']?.toString();
        if (appId == null || appId.isEmpty) continue;

        reservationsByApp.putIfAbsent(appId, () => []).add({
          'date_debut': row['date_debut'],
          'date_fin': row['date_fin'],
        });
      }

      //CALCUL DU STATUT
      final Map<String, bool> result = {};

      for (final appId in appartementIds) {
        // a) Dans une plage de dispo ?
        final dispos = disposByApp[appId] ?? [];
        bool dansPlageDispo = false;

        for (final d in dispos) {
          try {
            final start = DateTime.parse(d['date_debut'].toString());
            final end = DateTime.parse(d['date_fin'].toString());

            final startN = DateTime(start.year, start.month, start.day);
            final endN = DateTime(end.year, end.month, end.day);

            debugPrint('$appId : plage [$startN → $endN], today=$today');

            if (!today.isBefore(startN) && !today.isAfter(endN)) {
              dansPlageDispo = true;
              debugPrint('dans la plage');
              break;
            }
          } catch (e) {
            debugPrint('parse error : $e');
            continue;
          }
        }

        if (!dansPlageDispo) {
          result[appId] = false;
          debugPrint('$appId : hors plage dispo');
          continue;
        }

        // b) Bloqué par réservation ?
        final reservations = reservationsByApp[appId] ?? [];
        bool bloqueParReservation = false;

        for (final r in reservations) {
          try {
            final rStart = DateTime.parse(r['date_debut'].toString());
            final rEnd = DateTime.parse(r['date_fin'].toString());

            final rStartN = DateTime(rStart.year, rStart.month, rStart.day);
            final rEndN = DateTime(rEnd.year, rEnd.month, rEnd.day);

            if (!today.isBefore(rStartN) && today.isBefore(rEndN)) {
              bloqueParReservation = true;
              break;
            }
          } catch (_) {
            continue;
          }
        }

        result[appId] = !bloqueParReservation;
        debugPrint('$appId : dispo=${result[appId]}');
      }

      debugPrint('RÉSULTAT FINAL : $result');
      return result;
    } on PostgrestException catch (e) {
      debugPrint('Postgrest : ${e.message} | code: ${e.code}');
      debugPrint('   details: ${e.details}');
      return {};
    } catch (e) {
      debugPrint('Erreur : $e');
      return {};
    }
  }

  // PROFIL UTILISATEUR
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final userId = currentUserId();

    if (userId == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      final response = await supabase
          .from('users')
          .select('''
            id,
            email,
            nom,
            prenom,
            telephone,
            indicatif_telephone,
            pays,
            adresse,
            urgencephone,
            ville,
            date_naissance,
            role,
            statut,
            est_certifie,
            date_certification,
            certifie_par,
            identite_verifiee,
            date_verification_identite,
            verifie_par,
            photo_profil,
            description,
            preferences,
            created_at,
            updated_at
          ''')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return Map<String, dynamic>.from(response);
    } on PostgrestException catch (e) {
      debugPrint(
        'getCurrentUserProfile : ${e.message}',
      );
      throw Exception(e.message);
    } catch (e) {
      debugPrint(
        'Erreur getCurrentUserProfile : $e',
      );
      rethrow;
    }
  }

  Future<void> updateCurrentUserProfile({
    String? nom,
    String? prenom,
    String? telephone,
    String? indicatifTelephone,
    String? pays,
    String? adresse,
    String? urgencephone,
    String? ville,
    DateTime? dateNaissance,
    String? description,
  }) async {
    final userId = currentUserId();

    if (userId == null) {
      throw Exception('Utilisateur non connecté.');
    }

    final Map<String, dynamic> updates = {};

    if (nom != null) {
      updates['nom'] = nom.trim();
    }

    if (prenom != null) {
      updates['prenom'] = prenom.trim();
    }

    if (telephone != null) {
      updates['telephone'] = telephone.trim();
    }

    if (indicatifTelephone != null) {
      updates['indicatif_telephone'] =
          indicatifTelephone.trim();
    }

    if (pays != null) {
      updates['pays'] = pays.trim();
    }

    if (adresse != null) {
      updates['adresse'] = adresse.trim();
    }

    if (urgencephone != null) {
      updates['urgencephone'] = urgencephone.trim();
    }

    if (ville != null) {
      updates['ville'] = ville.trim();
    }

    if (dateNaissance != null) {
      updates['date_naissance'] =
          dateNaissance.toIso8601String().split('T').first;
    }

    if (description != null) {
      updates['description'] = description.trim();
    }

    if (updates.isEmpty) {
      return;
    }

    try {
      await supabase
          .from('users')
          .update(updates)
          .eq('id', userId);

      debugPrint(
        'Profil utilisateur mis à jour : $userId',
      );
    } on PostgrestException catch (e) {
      debugPrint(
        'updateCurrentUserProfile : ${e.message}',
      );
      throw Exception(e.message);
    } catch (e) {
      debugPrint(
        'Erreur updateCurrentUserProfile : $e',
      );
      rethrow;
    }
  }

  // AVATAR UTILISATEUR
  Future<String?> uploadCurrentUserAvatar({
    required Uint8List bytes,
    required String extension,
    required String mimeType,
  }) async {
    final userId = currentUserId();

    if (userId == null) {
      throw Exception('Utilisateur non connecté.');
    }

    if (bytes.isEmpty) {
      throw Exception('L’image est vide.');
    }

    if (bytes.length > 5 * 1024 * 1024) {
      throw Exception(
        'L’image ne doit pas dépasser 5 Mo.',
      );
    }

    final normalizedExtension =
    extension.trim().toLowerCase().replaceFirst('.', '');

    const allowedExtensions = {
      'jpg',
      'jpeg',
      'png',
      'webp',
    };

    if (!allowedExtensions.contains(normalizedExtension)) {
      throw Exception(
        'Format d’image non autorisé.',
      );
    }

    final allowedMimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
    };

    final expectedMimeType =
    allowedMimeTypes[normalizedExtension];

    if (expectedMimeType == null ||
        mimeType != expectedMimeType) {
      throw Exception(
        'Type MIME de l’image invalide.',
      );
    }

    final String storagePath =
        '$userId/avatar.$normalizedExtension';

    try {

      // Upload dans le bucket privé "avatars"
      await supabase.storage
          .from('avatars')
          .uploadBinary(
        storagePath,
        bytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: mimeType,
          cacheControl: '3600',
        ),
      );

      await supabase
          .from('users')
          .update({
        'photo_profil': storagePath,
      })
          .eq('id', userId);

      debugPrint(
        'Avatar utilisateur enregistré : $storagePath',
      );

      return storagePath;
    } on PostgrestException catch (e) {
      debugPrint(
        'uploadCurrentUserAvatar DB : ${e.message}',
      );
      throw Exception(e.message);
    } catch (e) {
      debugPrint(
        'Erreur uploadCurrentUserAvatar : $e',
      );
      rethrow;
    }
  }

  Future<String?> getCurrentUserAvatarUrl({
    int expiresIn = 3600,
  }) async {
    final userId = currentUserId();

    if (userId == null) {
      return null;
    }

    try {
      final response = await supabase
          .from('users')
          .select('photo_profil')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      final path =
      response['photo_profil']?.toString();

      if (path == null || path.trim().isEmpty) {
        return null;
      }

      return await supabase.storage
          .from('avatars')
          .createSignedUrl(
        path,
        expiresIn,
      );
    } on PostgrestException catch (e) {
      debugPrint(
        'getCurrentUserAvatarUrl DB : ${e.message}',
      );
      return null;
    } catch (e) {
      debugPrint(
        'Erreur getCurrentUserAvatarUrl : $e',
      );
      return null;
    }
  }

  Future<void> deleteCurrentUserAvatar() async {
    final userId = currentUserId();

    if (userId == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      final response = await supabase
          .from('users')
          .select('photo_profil')
          .eq('id', userId)
          .maybeSingle();

      final path =
      response?['photo_profil']?.toString();

      // Suppression du fichier Storage
      if (path != null && path.trim().isNotEmpty) {
        try {
          await supabase.storage
              .from('avatars')
              .remove([path]);
        } catch (e) {
          debugPrint(
            'Suppression fichier avatar échouée : $e',
          );
        }
      }

      // Suppression de la référence dans users
      await supabase
          .from('users')
          .update({
        'photo_profil': null,
      })
          .eq('id', userId);

      debugPrint(
        'Avatar utilisateur supprimé.',
      );
    } on PostgrestException catch (e) {
      debugPrint(
        'deleteCurrentUserAvatar DB : ${e.message}',
      );
      throw Exception(e.message);
    } catch (e) {
      debugPrint(
        'Erreur deleteCurrentUserAvatar : $e',
      );
      rethrow;
    }
  }


  // AVATAR D'UN UTILISATEUR
  Future<String?> getUserAvatarUrl(
      String userId, {
        int expiresIn = 3600,
      }) async {
    if (userId.trim().isEmpty) {
      return null;
    }

    try {
      final response = await supabase
          .from('users')
          .select('photo_profil')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      final path = response['photo_profil']?.toString().trim();

      if (path == null || path.isEmpty) {
        return null;
      }

      return await supabase.storage
          .from('avatars')
          .createSignedUrl(
        path,
        expiresIn,
      );
    } on PostgrestException catch (e) {
      debugPrint(
        'getUserAvatarUrl DB : ${e.message}',
      );
      return null;
    } catch (e) {
      debugPrint(
        'getUserAvatarUrl : $e',
      );
      return null;
    }
  }

  // AVATARS DE PLUSIEURS UTILISATEURS
  Future<Map<String, String>> getUsersAvatarUrls(
      List<String> userIds, {
        int expiresIn = 3600,
      }) async {
    final ids = userIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (ids.isEmpty) {
      return {};
    }

    try {
      final response = await supabase
          .from('users')
          .select('id, photo_profil')
          .inFilter('id', ids);

      final result = <String, String>{};

      for (final item in response) {
        final userId = item['id']?.toString();
        final path = item['photo_profil']?.toString().trim();

        if (userId == null ||
            userId.isEmpty ||
            path == null ||
            path.isEmpty) {
          continue;
        }

        try {
          final signedUrl = await supabase.storage
              .from('avatars')
              .createSignedUrl(
            path,
            expiresIn,
          );

          result[userId] = signedUrl;
        } catch (e) {
          debugPrint(
            'Avatar impossible pour $userId : $e',
          );
        }
      }

      return result;
    } on PostgrestException catch (e) {
      debugPrint(
        'getUsersAvatarUrls DB : ${e.message}',
      );
      return {};
    } catch (e) {
      debugPrint(
        'getUsersAvatarUrls : $e',
      );
      return {};
    }
  }


  // VÉRIFICATION ANTI-DOUBLON DOCUMENT D'IDENTITÉ

  Future<Map<String, dynamic>?> findExistingIdentityDocument({
    required String numeroDocument,
    required String paysEmission,
    required String typeDocument,
  }) async {
    final userId = currentUserId();

    if (userId == null) {
      throw Exception('Utilisateur non connecté.');
    }

    final normalizedNumero = _normalizeDocumentNumber(numeroDocument);
    final normalizedPays = paysEmission.trim();

    try {
      final response = await supabase
          .from('documents')
          .select('''
          id,
          type_document,
          cote_document,
          numero_document,
          pays_emission,
          statut,
          created_at
        ''')
          .eq('user_id', userId)
          .eq('categorie', 'identite')
          .eq('type_document', typeDocument)
          .eq('numero_document', normalizedNumero)
          .eq('pays_emission', normalizedPays)
          .inFilter('statut', ['en_attente', 'en_verification', 'valide'])
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return Map<String, dynamic>.from(response);
    } on PostgrestException catch (e) {
      debugPrint('findExistingIdentityDocument : ${e.message}');
      return null;
    }
  }

  // AJOUT D'UN DOCUMENT UTILISATEUR / RÉSIDENCE / APPARTEMENT
  Future<Map<String, dynamic>> uploadCurrentUserDocument({
    required Uint8List bytes,
    required String typeDocument,
    required String nomFichier,
    required String mimeType,

    String categorie = 'identite',

    String? residenceId,
    String? appartementId,

    String? coteDocument,
    String? numeroDocument,
    DateTime? dateEmission,
    DateTime? dateExpiration,
    String? paysEmission,

    bool obligatoire = false,
  }) async {
    final userId = currentUserId();

    if (userId == null) {
      throw Exception('Utilisateur non connecté.');
    }

    // VALIDATION DU PARENT
    final hasResidence = residenceId != null &&
        residenceId.trim().isNotEmpty;

    final hasAppartement = appartementId != null &&
        appartementId.trim().isNotEmpty;

    if (hasResidence && hasAppartement) {
      throw Exception(
        'Un document ne peut être associé simultanément '
            'à une résidence et à un appartement.',
      );
    }


    // VALIDATION FICHIER

    if (bytes.isEmpty) {
      throw Exception('Le document est vide.');
    }

    const maxSize = 50 * 1024 * 1024;

    if (bytes.length > maxSize) {
      throw Exception(
        'Le document ne doit pas dépasser 50 Mo.',
      );
    }

    // VALIDATION CATÉGORIE
    final normalizedCategorie =
    categorie.trim().toLowerCase();

    const allowedCategories = {
      'identite',
      'propriete',
      'fiscal',
      'administratif',
      'autre',
    };

    if (!allowedCategories.contains(normalizedCategorie)) {
      throw Exception(
        'Catégorie de document non autorisée.',
      );
    }

    // VALIDATION TYPE
    final normalizedType = typeDocument.trim();

    if (normalizedType.isEmpty) {
      throw Exception(
        'Le type du document est obligatoire.',
      );
    }


    // VALIDATION CÔTÉ
    String? normalizedCote;

    if (coteDocument != null &&
        coteDocument.trim().isNotEmpty) {
      normalizedCote =
          coteDocument.trim().toLowerCase();

      const allowedSides = {
        'recto',
        'verso',
      };

      if (!allowedSides.contains(normalizedCote)) {
        throw Exception(
          'Le côté du document doit être "recto" ou "verso".',
        );
      }
    }


    // NOM FICHIER
    final originalFileName = nomFichier.trim();

    if (originalFileName.isEmpty) {
      throw Exception(
        'Le nom du fichier est obligatoire.',
      );
    }

    final normalizedMimeType =
    mimeType.trim().toLowerCase();

    if (normalizedMimeType.isEmpty) {
      throw Exception(
        'Le type MIME est obligatoire.',
      );
    }


    // NETTOYAGE DU NOM
    final safeFileName = originalFileName
        .replaceAll(
      RegExp(r'[\\/:*?"<>|]'),
      '_',
    )
        .replaceAll(
      RegExp(r'\s+'),
      '_',
    );

    // EXTENSION
    String extension = '';

    final lastDot = safeFileName.lastIndexOf('.');

    if (lastDot > 0 &&
        lastDot < safeFileName.length - 1) {
      extension = safeFileName
          .substring(lastDot + 1)
          .toLowerCase();
    }

    if (extension.isEmpty) {
      extension = _extensionFromMimeType(normalizedMimeType,);
    }

    if (extension.isEmpty) {
      throw Exception(
        'Impossible de déterminer le format du document.',
      );
    }

    // NOM UNIQUE STORAGE
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storageFileName = '${timestamp}_$safeFileName';

    // STORAGE

    final storagePath =
        'users/$userId/'
        '$normalizedCategorie/'
        '$storageFileName';

    try {

      // UPLOAD STORAGE
      await supabase.storage
          .from('documents')
          .uploadBinary(
        storagePath,
        bytes,
        fileOptions: FileOptions(
          upsert: false,
          contentType: normalizedMimeType,
        ),
      );


      // DÉTERMINATION DU PARENT
      final String? documentUserId =
      (!hasResidence && !hasAppartement)
          ? userId
          : null;

      final String? documentResidenceId =
      hasResidence
          ? residenceId.trim()
          : null;

      final String? documentAppartementId =
      hasAppartement
          ? appartementId.trim()
          : null;

      final session = supabase.auth.currentSession;
      final authUser = supabase.auth.currentUser;

      debugPrint('user.id      = ${authUser?.id}');
      debugPrint('session      = ${session != null}');
      debugPrint('accessToken  = ${session?.accessToken != null}');
      debugPrint('user.role    = ${authUser?.role}');
      debugPrint('user.metadata= ${authUser?.userMetadata}');
      debugPrint('expiresAt    = ${session?.expiresAt}');
      debugPrint(
        'AUTH CHECK => '
            'currentUserId=$userId | '
            'supabase.auth.currentUser?.id=${authUser?.id} | '
            'hasSession=${supabase.auth.currentSession != null}',
      );

      debugPrint(
        'INSERT DOCUMENT => '
            'user_id=$documentUserId | '
            'residence_id=$documentResidenceId | '
            'appartement_id=$documentAppartementId | '
            'categorie=$normalizedCategorie | '
            'type=$normalizedType',
      );

      // INSERT DATABASE
      final response = await supabase
          .from('documents')
          .insert({

        // PARENT
        'user_id': documentUserId,
        'residence_id': documentResidenceId,
        'appartement_id': documentAppartementId,

        //INFORMATIONS DOCUMENT
        'categorie': normalizedCategorie,
        'type_document': normalizedType,
        'cote_document': normalizedCote,
        'nom_fichier': originalFileName,
        'chemin_fichier': storagePath,
        'mime_type': normalizedMimeType,
        'taille_fichier': bytes.length,
        'numero_document': numeroDocument?.trim().isEmpty == true ? null : numeroDocument?.trim(),

        'date_emission': dateEmission ?.toIso8601String().split('T').first,
        'date_expiration': dateExpiration?.toIso8601String().split('T').first,

        'pays_emission': paysEmission?.trim().isEmpty == true ? null : paysEmission?.trim(),
        'statut': 'en_attente',
        'obligatoire': obligatoire,
      })
          .select('''
          id,
          user_id,
          residence_id,
          appartement_id,
          categorie,
          type_document,
          cote_document,
          nom_fichier,
          chemin_fichier,
          mime_type,
          taille_fichier,
          numero_document,
          date_emission,
          date_expiration,
          pays_emission,
          statut,
          motif_refus,
          verifie_par,
          date_verification,
          obligatoire,
          created_at,
          updated_at
        ''')
          .single();

      debugPrint(
        'Document ajouté : '
            '$storagePath | '
            'user_id=$documentUserId | '
            'residence_id=$documentResidenceId | '
            'appartement_id=$documentAppartementId | '
            'côté=$normalizedCote',
      );

      return Map<String, dynamic>.from(response);
    } on PostgrestException catch (e) {
      // Nettoyage Storage...
      try {
        await supabase.storage
            .from('documents')
            .remove([storagePath]);
      } catch (cleanupError) {
        debugPrint('Nettoyage Storage impossible : $cleanupError');
      }

      // Contrainte UNIQUE violée → doublon
      if (e.code == '23505') {
        throw Exception(
          'Ce document existe déjà. '
              'Supprimez l’ancien avant d’en envoyer un nouveau.',
        );
      }

      debugPrint('uploadCurrentUserDocument DB : ${e.message}');
      throw Exception(e.message);
    }
  }

  // UPLOAD D'UN DOCUMENT D'IDENTITÉ (CNI ou PASSEPORT) — AVEC ANTI-DOUBLON

  Future<void> uploadIdentityCardDocuments({
    required Uint8List rectoBytes,

    Uint8List? versoBytes,

    required String numeroDocument,
    required DateTime dateEmission,
    required DateTime dateExpiration,
    required String paysEmission,

    String typeDocument = 'carte_identite',
  }) async {
    // VALIDATION UTILISATEUR
    final userId = currentUserId();

    if (userId == null) {
      throw Exception('Utilisateur non connecté.');
    }

    // DÉTERMINATION DU MODE
    final bool isPassport = typeDocument == 'passeport';
    final bool requiresVerso = !isPassport;

    // VALIDATION RECTO
    if (rectoBytes.isEmpty) {
      throw Exception(
        isPassport
            ? 'La photo du passeport est obligatoire.'
            : 'La photo du recto est obligatoire.',
      );
    }

    // VALIDATION VERSO (uniquement pour la CNI)
    if (requiresVerso) {
      if (versoBytes == null || versoBytes.isEmpty) {
        throw Exception('La photo du verso est obligatoire.');
      }
    }

    // LIMITE DE TAILLE
    const maxSize = 50 * 1024 * 1024;

    if (rectoBytes.length > maxSize) {
      throw Exception(
        isPassport
            ? 'La photo du passeport ne doit pas dépasser 50 Mo.'
            : 'La photo du recto ne doit pas dépasser 50 Mo.',
      );
    }

    if (requiresVerso && versoBytes != null) {
      if (versoBytes.length > maxSize) {
        throw Exception(
          'La photo du verso ne doit pas dépasser 50 Mo.',
        );
      }
    }

    // VALIDATION NUMÉRO
    final normalizedNumero = numeroDocument.trim();

    if (normalizedNumero.isEmpty) {
      throw Exception('Le numéro du document est obligatoire.');
    }

    // VALIDATION PAYS
    final normalizedPays = paysEmission.trim();

    if (normalizedPays.isEmpty) {
      throw Exception('Le pays d’émission est obligatoire.');
    }

    // VALIDATION DATES
    if (dateExpiration.isBefore(dateEmission)) {
      throw Exception(
        'La date d’expiration doit être postérieure '
            'à la date d’émission.',
      );
    }

    // 🔴 ANTI-DOUBLON — VÉRIFICATION AVANT UPLOAD
    final existing = await findExistingIdentityDocument(
      numeroDocument: normalizedNumero,
      paysEmission: normalizedPays,
      typeDocument: typeDocument,
    );

    if (existing != null) {
      final statut = existing['statut']?.toString() ?? 'inconnu';
      final cote = existing['cote_document']?.toString();

      final coteLabel = cote == 'recto'
          ? ' (recto)'
          : cote == 'verso'
          ? ' (verso)'
          : '';

      throw Exception(
        'Ce document$coteLabel est déjà enregistré '
            'dans votre compte (statut : $statut).\n'
            'Si vous devez le remplacer, supprimez-le '
            'depuis vos documents avant de le renvoyer.',
      );
    }

    // NOMS DES FICHIERS
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final rectoFileName = isPassport
        ? 'passeport_$timestamp.jpg'
        : 'carte_identite_recto_$timestamp.jpg';

    final versoFileName = requiresVerso
        ? 'carte_identite_verso_$timestamp.jpg'
        : null;

    // PATHS STORAGE
    String? rectoPath;
    String? versoPath;
    String? rectoDocumentId;
    String? versoDocumentId;

    try {
      // UPLOAD RECTO (ou photo unique passeport)
      final rectoDocument = await uploadCurrentUserDocument(
        bytes: rectoBytes,
        typeDocument: typeDocument,
        nomFichier: rectoFileName,
        mimeType: 'image/jpeg',
        categorie: 'identite',

        coteDocument: requiresVerso ? 'recto' : null,

        numeroDocument: normalizedNumero,
        dateEmission: dateEmission,
        dateExpiration: dateExpiration,
        paysEmission: normalizedPays,
        obligatoire: true,
      );

      rectoPath = rectoDocument['chemin_fichier']?.toString();
      rectoDocumentId = rectoDocument['id']?.toString();

      if (rectoPath == null || rectoPath.trim().isEmpty) {
        throw Exception(
          'Le chemin Storage du document est introuvable.',
        );
      }

      // UPLOAD VERSO (uniquement CNI)
      if (requiresVerso && versoBytes != null && versoFileName != null) {
        final versoDocument = await uploadCurrentUserDocument(
          bytes: versoBytes,
          typeDocument: typeDocument,
          nomFichier: versoFileName,
          mimeType: 'image/jpeg',
          categorie: 'identite',
          coteDocument: 'verso',
          numeroDocument: normalizedNumero,
          dateEmission: dateEmission,
          dateExpiration: dateExpiration,
          paysEmission: normalizedPays,
          obligatoire: true,
        );

        versoPath = versoDocument['chemin_fichier']?.toString();
        versoDocumentId = versoDocument['id']?.toString();

        if (versoPath == null || versoPath.trim().isEmpty) {
          throw Exception(
            'Le chemin Storage du verso est introuvable.',
          );
        }
      }

      // SUCCÈS
      if (isPassport) {
        debugPrint('Passeport envoyé : $rectoPath');
      } else {
        debugPrint('CNI complète envoyée : RECTO + VERSO');
        debugPrint('RECTO => $rectoPath');
        debugPrint('VERSO => $versoPath');
      }
    } catch (e) {
      // NETTOYAGE STORAGE + DB en cas d'échec

      if (rectoPath != null && rectoPath.trim().isNotEmpty) {
        try {
          await supabase.storage
              .from('documents')
              .remove([rectoPath]);
        } catch (cleanupError) {
          debugPrint(
            'Impossible de supprimer le fichier recto : $cleanupError',
          );
        }
      }

      if (versoPath != null && versoPath.trim().isNotEmpty) {
        try {
          await supabase.storage
              .from('documents')
              .remove([versoPath]);
        } catch (cleanupError) {
          debugPrint(
            'Impossible de supprimer le fichier verso : $cleanupError',
          );
        }
      }

      // Suppression des lignes DB par ID (beaucoup plus fiable
      // que par numéro/côté, qui pouvait supprimer les mauvaises lignes)
      if (rectoDocumentId != null) {
        try {
          await supabase
              .from('documents')
              .delete()
              .eq('id', rectoDocumentId);
        } catch (cleanupDbError) {
          debugPrint(
            'Impossible de supprimer la ligne recto : $cleanupDbError',
          );
        }
      }

      if (versoDocumentId != null) {
        try {
          await supabase
              .from('documents')
              .delete()
              .eq('id', versoDocumentId);
        } catch (cleanupDbError) {
          debugPrint(
            'Impossible de supprimer la ligne verso : $cleanupDbError',
          );
        }
      }

      debugPrint(
        'Échec upload ${isPassport ? 'passeport' : 'CNI'} : $e',
      );

      rethrow;
    }
  }


  // DÉTERMINATION DE L'EXTENSION PAR TYPE MIME

  String _extensionFromMimeType(String mimeType) {
    switch (mimeType) {
      case 'application/pdf':
        return 'pdf';

      case 'image/jpeg':
        return 'jpg';

      case 'image/png':
        return 'png';

      case 'image/webp':
        return 'webp';

      case 'image/heic':
        return 'heic';

      case 'image/heif':
        return 'heif';

      default:
        return '';
    }
  }


  // NORMALISATION DU NUMÉRO DE DOCUMENT

  String _normalizeDocumentNumber(String input) {
    return input
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[-_.]'), '');
  }

  // DOCUMENTS UTILISATEUR

  Future<List<Map<String, dynamic>>> getCurrentUserDocuments({
    String? categorie,
  }) async {
    final userId = currentUserId();

    if (userId == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {
      dynamic query = supabase
          .from('documents')
          .select('''
            id,
            user_id,
            residence_id,
            appartement_id,
            categorie,
            type_document,
            nom_fichier,
            chemin_fichier,
            mime_type,
            taille_fichier,
            numero_document,
            cote_document,
            date_emission,
            date_expiration,
            pays_emission,
            statut,
            motif_refus,
            verifie_par,
            date_verification,
            obligatoire,
            created_at,
            updated_at
          ''')
          .eq('user_id', userId);

      if (categorie != null && categorie.trim().isNotEmpty) {
        query = query.eq(
          'categorie',
          categorie.trim(),
        );
      }

      final response = await query.order(
        'created_at',
        ascending: false,
      );

      return (response as List)
          .map(
            (item) => Map<String, dynamic>.from(item),
      )
          .toList();
    } on PostgrestException catch (e) {
      debugPrint(
        'getCurrentUserDocuments : ${e.message}',
      );
      throw Exception(e.message);
    } catch (e) {
      debugPrint(
        'Erreur getCurrentUserDocuments : $e',
      );
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCurrentUserResidenceDocuments({
    String? residenceId,
    String? categorie,
  }) async {
    final userId = currentUserId();

    if (userId == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {

      //Recupérer les résidences appartenant au propriétaire

      dynamic residencesQuery = supabase
          .from('residences')
          .select('id')
          .eq('proprietaire_id', userId);

      if (residenceId != null &&
          residenceId.trim().isNotEmpty) {
        residencesQuery = residencesQuery.eq(
          'id',
          residenceId.trim(),
        );
      }

      final residencesResponse = await residencesQuery;

      final residenceIds = (residencesResponse as List)
          .map((item) => item['id']?.toString())
          .whereType<String>()
          .toList();

      if (residenceIds.isEmpty) {
        return [];
      }

      //Récupérer les documents de ces résidences
      dynamic documentsQuery = supabase
          .from('documents')
          .select('''
          id,
          user_id,
          residence_id,
          appartement_id,
          categorie,
          type_document,
          nom_fichier,
          chemin_fichier,
          mime_type,
          taille_fichier,
          numero_document,
          cote_document,
          date_emission,
          date_expiration,
          pays_emission,
          statut,
          motif_refus,
          verifie_par,
          date_verification,
          obligatoire,
          created_at,
          updated_at
        ''')
          .inFilter('residence_id', residenceIds);

      if (categorie != null &&
          categorie.trim().isNotEmpty) {
        documentsQuery = documentsQuery.eq(
          'categorie',
          categorie.trim(),
        );
      }

      final response = await documentsQuery.order(
        'created_at',
        ascending: false,
      );

      return (response as List)
          .map(
            (item) => Map<String, dynamic>.from(item),
      )
          .toList();
    } on PostgrestException catch (e) {
      debugPrint(
        'getCurrentUserResidenceDocuments : ${e.message}',
      );
      throw Exception(e.message);
    } catch (e) {
      debugPrint(
        'Erreur getCurrentUserResidenceDocuments : $e',
      );
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>>
  getCurrentUserIdentityDocuments() async {
    return getCurrentUserDocuments(
      categorie: 'identite',
    );
  }

  // STORAGE
  Future<Uint8List?> downloadFileAsBytes({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      return await supabase.storage
          .from(bucketName)
          .download(filePath);
    } catch (e) {
      debugPrint(
        'downloadFileAsBytes: $e',
      );
      return null;
    }
  }

  Future<String?> getSignedUrl({
    required String bucketName,
    required String filePath,
    int expiresIn = 3600,
  }) async {
    try {
      return await supabase.storage
          .from(bucketName)
          .createSignedUrl(
        filePath,
        expiresIn,
      );
    } catch (e) {
      debugPrint(
        'getSignedUrl: $e',
      );
      return null;
    }
  }

  // SUPPRESSION D'UN DOCUMENT UTILISATEUR
  Future<void> deleteCurrentUserDocument(
      String documentId,
      ) async {
    final userId = currentUserId();

    if (userId == null) {
      throw Exception('Utilisateur non connecté.');
    }

    try {

      // Récupérer le document appartenant à l'utilisateur
      final document = await supabase
          .from('documents')
          .select('id, user_id, chemin_fichier')
          .eq('id', documentId)
          .eq('user_id', userId)
          .maybeSingle();

      if (document == null) {
        throw Exception(
          'Document introuvable ou accès non autorisé.',
        );
      }

      final filePath =
      document['chemin_fichier']?.toString();

      // SUPPRESSION STORAGE
      if (filePath != null &&
          filePath.trim().isNotEmpty) {
        await supabase.storage
            .from('documents')
            .remove([filePath]);

        debugPrint(
          'Fichier Storage supprimé : $filePath',
        );
      }

      // SUPPRESSION BASE DE DONNÉES
      await supabase
          .from('documents')
          .delete()
          .eq('id', documentId)
          .eq('user_id', userId);

    } on PostgrestException catch (e) {
      debugPrint(
        'deleteCurrentUserDocument : ${e.message}',
      );
      throw Exception(e.message);
    } catch (e) {
      debugPrint(
        'Erreur deleteCurrentUserDocument : $e',
      );
      rethrow;
    }
  }


  // RECHERCHE APPARTEMENTS
  Future<List<Map<String, dynamic>>>
  searchAppartements({
    String? query,
    String? ville,
    String? type,
    num? minPrix,
    num? maxPrix,
    int limit = 20,
  }) async {
    try {
      var request = supabase
          .from('appartements')
          .select('''
          *,
          residence:residences!appartements_residence_id_fkey (
            id,
            nom,
            ville,
            adresse,
            localisation,
            status
          )
        ''')
          .eq('status', 'publie');

      if (ville != null &&
          ville.trim().isNotEmpty) {
        request = request.eq(
          'residence.ville',
          ville.trim(),
        );
      }

      if (type != null &&
          type.trim().isNotEmpty) {
        request = request.eq(
          'type',
          type.trim(),
        );
      }

      if (minPrix != null) {
        request = request.gte(
          'prix',
          minPrix,
        );
      }

      if (maxPrix != null) {
        request = request.lte(
          'prix',
          maxPrix,
        );
      }

      final results = await request
          .order(
        'created_at',
        ascending: false,
      )
          .limit(limit);

      final allResults =
      List<Map<String, dynamic>>.from(results);

      if (query == null ||
          query.trim().isEmpty) {
        return allResults;
      }

      final queryLower =
      query.trim().toLowerCase();

      return allResults.where((appartement) {
        final titre =
        (appartement['titre'] ?? '')
            .toString()
            .toLowerCase();

        final description =
        (appartement['description'] ?? '')
            .toString()
            .toLowerCase();

        final residence =
        appartement['residence'];

        String nomResidence = '';
        String adresse = '';
        String villeValue = '';

        if (residence is Map) {
          nomResidence =
              (residence['nom'] ?? '')
                  .toString()
                  .toLowerCase();

          adresse =
              (residence['adresse'] ?? '')
                  .toString()
                  .toLowerCase();

          villeValue =
              (residence['ville'] ?? '')
                  .toString()
                  .toLowerCase();
        }

        return titre.contains(queryLower) ||
            description.contains(queryLower) ||
            nomResidence.contains(queryLower) ||
            adresse.contains(queryLower) ||
            villeValue.contains(queryLower);
      }).toList();
    } catch (e) {
      debugPrint(
        'searchAppartements: $e',
      );
      return [];
    }
  }

  // NOTES
  Future<int?> getUserRating(
      String appartementId,
      ) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        return null;
      }

      final response = await supabase
          .from('ratings')
          .select('rating')
          .eq(
        'appartement_id',
        appartementId,
      )
          .eq(
        'user_id',
        user.id,
      )
          .maybeSingle();

      if (response == null) {
        return null;
      }

      final value = response['rating'];

      if (value is int) {
        return value;
      }

      return int.tryParse(
        value.toString(),
      );
    } catch (e) {
      debugPrint(
        'getUserRating: $e',
      );
      return null;
    }
  }

  Future<void> rateAppartement({
    required String appartementId,
    required int rating,
    String? comment,
  }) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception(
          'Utilisateur non connecté.',
        );
      }

      if (rating < 1 || rating > 5) {
        throw Exception(
          'La note doit être comprise entre 1 et 5.',
        );
      }

      await supabase.from('ratings').upsert(
        {
          'appartement_id': appartementId,
          'user_id': user.id,
          'rating': rating,
          'comment': comment,
          'updated_at':
          DateTime.now().toIso8601String(),
        },
        onConflict:
        'appartement_id,user_id',
      );
    } catch (e) {
      debugPrint(
        'rateAppartement: $e',
      );
      rethrow;
    }
  }

  Future<void> deleteRating(
      String appartementId,
      ) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception(
          'Utilisateur non connecté.',
        );
      }

      await supabase
          .from('ratings')
          .delete()
          .eq(
        'appartement_id',
        appartementId,
      )
          .eq(
        'user_id',
        user.id,
      );
    } catch (e) {
      debugPrint(
        'deleteRating: $e',
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>>
  getRatingStats(
      String appartementId,
      ) async {
    try {
      final response = await supabase.rpc(
        'get_rating_stats',
        params: {
          'app_id': appartementId,
        },
      );

      if (response == null) {
        return {
          'average': 0.0,
          'count': 0,
        };
      }

      if (response is List &&
          response.isEmpty) {
        return {
          'average': 0.0,
          'count': 0,
        };
      }

      if (response is List) {
        final data = response.first;

        return {
          'average':
          (data['average_rating'] ?? 0)
              .toDouble(),
          'count':
          data['ratings_count'] ?? 0,
        };
      }

      return {
        'average': 0.0,
        'count': 0,
      };
    } catch (e) {
      debugPrint(
        'getRatingStats: $e',
      );

      return {
        'average': 0.0,
        'count': 0,
      };
    }
  }

  //updateProfile (pour InformationsPersonnellesPage)
  Future<void> updateProfile({
    String? nom,
    String? prenom,
    String? telephone,
    String? urgencephone,
    String? ville,
    String? pays,
    String? adresse,
    DateTime? dateNaissance,
  }) async {
    return updateCurrentUserProfile(
      nom: nom,
      prenom: prenom,
      telephone: telephone,
      urgencephone: urgencephone,
      ville: ville,
      pays: pays,
      adresse: adresse,
      dateNaissance: dateNaissance,
    );
  }

  //getCurrentProfile
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    return getCurrentUserProfile();
  }

  // STATUT DE CERTIFICATION DU PROPRIÉTAIRE
  Future<Map<String, dynamic>> getCertificationStatus() async {
    final userId = currentUserId();

    if (userId == null) {
      return {
        'is_certified': false,
        'profile_complete': false,
        'identity_verified': false,
        'missing_fields': <String>[],
        'missing_documents': <String>[],
        'progress': 0.0,
      };
    }

    try {

      //PROFIL
      final profile = await supabase
          .from('users')
          .select('''
          nom,
          prenom,
          email,
          telephone,
          pays,
          ville,
          adresse,
          date_naissance,
          est_certifie,
          identite_verifiee
        ''')
          .eq('id', userId)
          .maybeSingle();

      if (profile == null) {
        return {
          'is_certified': false,
          'profile_complete': false,
          'identity_verified': false,
          'missing_fields': <String>['Profil introuvable'],
          'missing_documents': <String>[],
          'progress': 0.0,
        };
      }

      // Champs obligatoires
      final requiredFields = <String, String>{
        'nom': 'Nom',
        'prenom': 'Prénom',
        'email': 'Email',
        'telephone': 'Téléphone',
        'pays': 'Pays',
        'ville': 'Ville',
        'adresse': 'Adresse',
        'date_naissance': 'Date de naissance',
      };

      final missingFields = <String>[];

      for (final entry in requiredFields.entries) {
        final value = profile[entry.key]?.toString().trim() ?? '';
        if (value.isEmpty) {
          missingFields.add(entry.value);
        }
      }

      final profileComplete = missingFields.isEmpty;

      //DOCUMENTS D'IDENTITÉ
      final docsResponse = await supabase
          .from('documents')
          .select('type_document, cote_document, statut, date_expiration')
          .eq('user_id', userId)
          .eq('categorie', 'identite');

      final docs = List<Map<String, dynamic>>.from(docsResponse);

      // Filtre : statut valide + non expiré
      bool isValid(Map<String, dynamic> doc) {
        if (doc['statut'] != 'valide') return false;

        final exp = doc['date_expiration'];
        if (exp == null) return true;

        try {
          final date = DateTime.parse(exp.toString());
          return !date.isBefore(DateTime.now());
        } catch (_) {
          return true;
        }
      }

      final validDocs = docs.where(isValid).toList();

      final cniRectoValid = validDocs.any(
            (d) =>
        d['type_document'] == 'carte_identite' &&
            d['cote_document'] == 'recto',
      );

      final cniVersoValid = validDocs.any(
            (d) =>
        d['type_document'] == 'carte_identite' &&
            d['cote_document'] == 'verso',
      );

      final cniValid = cniRectoValid && cniVersoValid;

      final passportValid = validDocs.any(
            (d) => d['type_document'] == 'passeport',
      );

      final permisValid = validDocs.any(
            (d) => d['type_document'] == 'permis_conduire',
      );

      final identityVerified = cniValid || passportValid || permisValid;

      final missingDocuments = <String>[];

      if (!identityVerified) {
        missingDocuments.add("Pièce d'identité valide");
      }

      //CERTIFICATION FINALE
      final dbCertified = profile['est_certifie'] == true;
      final dbVerified = profile['identite_verifiee'] == true;

      final isCertified =
          dbCertified && dbVerified && identityVerified;


      //PROGRESSION
      const totalPoints = 9;
      final filledPoints =
          (requiredFields.length - missingFields.length) +
              (identityVerified ? 1 : 0);

      final progress = (filledPoints / totalPoints).clamp(0.0, 1.0);

      return {
        'is_certified': isCertified,
        'profile_complete': profileComplete,
        'identity_verified': identityVerified,
        'missing_fields': missingFields,
        'missing_documents': missingDocuments,
        'progress': progress,
      };
    } on PostgrestException catch (e) {
      debugPrint('getCertificationStatus : ${e.message}');

      return {
        'is_certified': false,
        'profile_complete': false,
        'identity_verified': false,
        'missing_fields': <String>[],
        'missing_documents': <String>[],
        'progress': 0.0,
      };
    } catch (e) {
      debugPrint('getCertificationStatus : $e');

      return {
        'is_certified': false,
        'profile_complete': false,
        'identity_verified': false,
        'missing_fields': <String>[],
        'missing_documents': <String>[],
        'progress': 0.0,
      };
    }
  }


}