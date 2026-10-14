import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
// DONNÉES COMPLÈTES D'UN APPARTEMENT
// ============================================================

class ApartmentDetailData {
  final List<Map<String, dynamic>> infos;
  final List<Map<String, dynamic>> roles;
  final Map<String, bool> equipements;
  final List<String> images;

  const ApartmentDetailData({
    required this.infos,
    required this.roles,
    required this.equipements,
    required this.images,
  });

  bool get hasData {
    return infos.isNotEmpty ||
        roles.isNotEmpty ||
        equipements.isNotEmpty ||
        images.isNotEmpty;
  }

  /// Nombre d'équipements actifs
  int get activeEquipementsCount =>
      equipements.values.where((v) => v).length;

  /// Fallback vide
  static const ApartmentDetailData empty = ApartmentDetailData(
    infos: [],
    roles: [],
    equipements: {},
    images: [],
  );
}

// ============================================================
// SERVICE DÉTAIL APPARTEMENT
// ============================================================

class ApartmentDetailService {
  final String id;
  final SupabaseClient client;

  ApartmentDetailService({
    required this.id,
    required this.client,
  });

  // ============================================================
  // CONSTANTES
  // ============================================================

  static const String _storageBucket = 'appartements';

  // ============================================================
  // ID NETTOYÉ
  // ============================================================

  String get _cleanId => id.trim();

  // ============================================================
  // FETCH GLOBAL
  // ============================================================

  Future<ApartmentDetailData> fetchAll() async {
    debugPrint('');
    debugPrint('═══════════════════════════════════════');
    debugPrint('🏠 FETCH ALL APPARTEMENT');
    debugPrint('🏠 ID : $_cleanId');
    debugPrint('═══════════════════════════════════════');

    // ✅ ID vide → retour vide
    if (_cleanId.isEmpty) {
      debugPrint('❌ ID appartement vide');
      return ApartmentDetailData.empty;
    }

    try {
      // ========================================================
      // CHARGEMENT EN PARALLÈLE
      // ========================================================

      final results = await Future.wait([
        _fetchPhotos(),
        _fetchInfos(),
        _fetchRoles(),
        _fetchEquipements(),
      ]);

      final photos = results[0] as List<String>;
      final infos = results[1] as List<Map<String, dynamic>>;
      final roles = results[2] as List<Map<String, dynamic>>;
      final equipements = results[3] as Map<String, bool>; // ✅ Map

      // ========================================================
      // RÉSULTAT FINAL
      // ========================================================

      debugPrint('');
      debugPrint('═══════════════════════════════════════');
      debugPrint('📊 RÉSULTAT FINAL');
      debugPrint('📸 Photos : ${photos.length}');
      debugPrint('ℹ️ Infos : ${infos.length}');
      debugPrint('👤 Rôles : ${roles.length}');
      debugPrint(
        '🛋️ Équipements : ${equipements.length} '
            '(${equipements.values.where((v) => v).length} actifs)',
      );
      debugPrint('═══════════════════════════════════════');

      return ApartmentDetailData(
        images: photos,
        infos: infos,
        roles: roles,
        equipements: equipements,
      );
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('❌ ERREUR FETCH ALL');
      debugPrint('❌ $e');
      debugPrint('$stackTrace');
      debugPrint('═══════════════════════════════════════');

      rethrow;
    }
  }

  // ============================================================
  // PHOTOS
  // ============================================================

  Future<List<String>> _fetchPhotos() async {
    debugPrint('');
    debugPrint('═══════════════════════════════════════');
    debugPrint('📸 RÉCUPÉRATION DES PHOTOS');
    debugPrint('📸 Appartement ID : $_cleanId');
    debugPrint('═══════════════════════════════════════');

    try {
      final response = await client
          .from('photo_appartements')
          .select('''
            id,
            appartement_id,
            fichiername,
            extension,
            titre,
            est_principale,
            ordre_affichage,
            uploaded_at
          ''')
          .eq('appartement_id', _cleanId)
          .order('est_principale', ascending: false)
          .order('ordre_affichage', ascending: true);

      final photos = List<Map<String, dynamic>>.from(response);

      debugPrint('📊 Photos trouvées : ${photos.length}');

      if (photos.isEmpty) {
        debugPrint('⚠️ Aucune photo liée à cet appartement.');
        debugPrint('⚠️ appartement_id recherché : $_cleanId');
        return [];
      }

      final List<String> urls = [];

      for (final photo in photos) {
        final filename =
            photo['fichiername']?.toString().trim() ?? '';

        if (filename.isEmpty) {
          debugPrint(
            '⚠️ fichiername vide pour la photo ${photo['id']}',
          );
          continue;
        }

        debugPrint('');
        debugPrint('📷 PHOTO TROUVÉE');
        debugPrint('   ID : ${photo['id']}');
        debugPrint(
          '   APPARTEMENT ID : ${photo['appartement_id']}',
        );
        debugPrint('   FICHIER : $filename');
        debugPrint(
          '   PRINCIPALE : ${photo['est_principale'] ?? false}',
        );
        debugPrint(
          '   ORDRE : ${photo['ordre_affichage'] ?? 0}',
        );

        final url = _buildPhotoUrl(filename);
        debugPrint('   🌐 URL : $url');

        urls.add(url);
      }

      debugPrint('');
      debugPrint('═══════════════════════════════════════');
      debugPrint('📸 TOTAL URLS PHOTOS : ${urls.length}');
      debugPrint('═══════════════════════════════════════');

      return urls;
    } on PostgrestException catch (e, stackTrace) {
      debugPrint('');
      debugPrint('❌ ERREUR SUPABASE PHOTOS');
      debugPrint('❌ Message : ${e.message}');
      debugPrint('❌ Code : ${e.code}');
      debugPrint('❌ Details : ${e.details}');
      debugPrint('❌ Hint : ${e.hint}');
      debugPrint('$stackTrace');
      debugPrint('═══════════════════════════════════════');

      return [];
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('❌ ERREUR PHOTOS');
      debugPrint('❌ $e');
      debugPrint('$stackTrace');
      debugPrint('═══════════════════════════════════════');

      return [];
    }
  }

  // ============================================================
  // CONSTRUCTION URL PHOTO
  // ============================================================

  String _buildPhotoUrl(String filename) {
    final cleanFilename = filename.trim();

    if (cleanFilename.isEmpty) return '';

    // CAS 1 : URL complète
    if (cleanFilename.startsWith('http://') ||
        cleanFilename.startsWith('https://')) {
      return cleanFilename;
    }

    final cleanId = _cleanId;

    // CAS 2 : chemin déjà présent
    if (cleanFilename == cleanId ||
        cleanFilename.startsWith('$cleanId/')) {
      return client.storage
          .from(_storageBucket)
          .getPublicUrl(cleanFilename);
    }

    // CAS 3 : nom seul → préfixer avec l'ID
    final storagePath = '$cleanId/$cleanFilename';

    return client.storage
        .from(_storageBucket)
        .getPublicUrl(storagePath);
  }

  // ============================================================
  // INFOS APPARTEMENT
  // ============================================================

  Future<List<Map<String, dynamic>>> _fetchInfos() async {
    debugPrint('ℹ️ Récupération des informations...');

    try {
      final response = await client
          .from('appartement_infos')
          .select()
          .eq('appartement_id', _cleanId);

      final data = List<Map<String, dynamic>>.from(response);

      debugPrint('ℹ️ Infos récupérées : ${data.length}');

      return data;
    } on PostgrestException catch (e, stackTrace) {
      debugPrint('');
      debugPrint('❌ ERREUR INFOS');
      debugPrint('❌ Message : ${e.message}');
      debugPrint('❌ Code : ${e.code}');
      debugPrint('❌ Details : ${e.details}');
      debugPrint('❌ Hint : ${e.hint}');
      debugPrint('$stackTrace');

      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur infos : $e');
      debugPrint('$stackTrace');

      return [];
    }
  }

  // ============================================================
  // RÈGLES / ROLES
  // ============================================================

  Future<List<Map<String, dynamic>>> _fetchRoles() async {
    debugPrint('👤 Récupération des règles...');

    try {
      final response = await client
          .from('appartement_role')
          .select()
          .eq('appartement_id', _cleanId);

      final data = List<Map<String, dynamic>>.from(response);

      debugPrint('👤 Rôles récupérés : ${data.length}');

      return data;
    } on PostgrestException catch (e, stackTrace) {
      debugPrint('');
      debugPrint('❌ ERREUR RÈGLES');
      debugPrint('❌ Message : ${e.message}');
      debugPrint('❌ Code : ${e.code}');
      debugPrint('❌ Details : ${e.details}');
      debugPrint('❌ Hint : ${e.hint}');
      debugPrint('$stackTrace');

      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur rôles : $e');
      debugPrint('$stackTrace');

      return [];
    }
  }

  // ============================================================
  // ÉQUIPEMENTS
  // ============================================================

  Future<Map<String, bool>> _fetchEquipements() async {
    debugPrint('🛋️ Récupération des équipements...');

    try {
      final response = await client
          .from('appartements')
          .select('autres_equipements')
          .eq('id', _cleanId)
          .maybeSingle();

      if (response == null) {
        debugPrint(
          '⚠️ Appartement introuvable pour les équipements.',
        );
        return {};
      }

      final rawEquipements = response['autres_equipements'];

      if (rawEquipements == null) {
        debugPrint('⚠️ Aucun équipement.');
        return {};
      }

      // ✅ Conversion Map<String, dynamic> → Map<String, bool>

      final Map<String, bool> result = {};

      if (rawEquipements is Map) {
        for (final entry in rawEquipements.entries) {
          final key = entry.key.toString();
          final value = entry.value;

          if (value is bool) {
            result[key] = value;
          } else if (value is String) {
            result[key] = value.toLowerCase() == 'true';
          } else if (value is num) {
            result[key] = value != 0;
          }
        }
      }

      debugPrint(
        '🛋️ Équipements récupérés : ${result.length}',
      );
      debugPrint(
        '🛋️ Actifs : ${result.values.where((v) => v).length}',
      );

      return result;
    } on PostgrestException catch (e, stackTrace) {
      debugPrint(
        '❌ ERREUR SUPABASE ÉQUIPEMENTS : ${e.message}',
      );
      debugPrint('$stackTrace');
      return {};
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur équipements : $e');
      debugPrint('$stackTrace');
      return {};
    }
  }
}