import 'package:image_picker/image_picker.dart';
import 'package:service/database_service.dart';

import '../data/models/add_appartement/appartement_create.dart';
import '../data/models/add_appartement/appartement_info_create.dart';
import '../data/models/add_appartement/appartement_role_create.dart';

class AddAppartementService {
  final DatabaseService _databaseService = DatabaseService();

  // ============================================================
  // CRÉATION APPARTEMENT
  // ============================================================
  //
  // L'appartement appartient obligatoirement à une résidence.
  //
  // La ville, l'adresse et la localisation ne sont plus stockées
  // dans appartements.
  // Elles appartiennent à residences.
  //
  // ============================================================

  Future<String> createAppartement(
      AppartementCreate appartement,
      ) async {
    if (appartement.residenceId == null ||
        appartement.residenceId!.trim().isEmpty) {
      throw Exception(
        'Veuillez sélectionner une résidence.',
      );
    }

    return await _databaseService.createAppartement(
      titre: appartement.titre,
      type: appartement.type,
      prix: appartement.prix,
      description: appartement.description,
      nbreSejour: appartement.nbreSejour,
      equipements: appartement.equipements,
      residenceId: appartement.residenceId!,
    );
  }

  // ============================================================
  // INFORMATIONS APPARTEMENT
  // ============================================================

  Future<String> insertAppartementInfo(
      String appartementId,
      AppartementInfoCreate info,
      ) async {
    final data = info.toMap();

    return await _databaseService.insertAppartementInfo(
      appartementId: appartementId,
      chambre: data['chambre'] as int,
      salon: data['salon'] as int,
      douche: data['douche'] as int,
      cuisine: data['cuisine'] as int,
      etage: data['etage'] as int,
      taille: (data['taille'] as num).toDouble(),
      serviceInclus: data['service_inclus'] as String,
      internet: data['internet'] as String,
      stationnement: data['stationnement'] as String,
      meuble: data['meuble'] as String,
      climatisation: data['climatisation'] as String,
    );
  }

  // ============================================================
  // RÈGLES APPARTEMENT
  // ============================================================

  Future<void> insertAppartementRole(
      String appartementId,
      AppartementRoleCreate role,
      ) async {
    await _databaseService.insertAppartementRole(
      appartementId: appartementId,
      description: role.description,
      heureArrive: role.heureArrive,
      heureDepart: role.heureDepart,
      nombreClient: role.nombreClient,
      fete: role.fete,
      animaux: role.animaux,
      fumeur: role.fumeur,
    );
  }

  // ============================================================
  // DISPONIBILITÉS
  // ============================================================

  Future<void> createDisponibilites(
      String appartementId,
      DateTime dateDebut,
      DateTime dateFin,
      ) async {
    await _databaseService.createDisponibilites(
      appartementId: appartementId,
      dateDebut: dateDebut,
      dateFin: dateFin,
    );
  }

  // ============================================================
  // PHOTOS
  // ============================================================

  Future<void> uploadPhotos(
      String appartementId,
      List<XFile> images,
      Function(int, int) onProgress,
      ) async {
    if (images.isEmpty) {
      throw Exception(
        'Veuillez sélectionner au moins une photo.',
      );
    }

    for (int i = 0; i < images.length; i++) {
      final image = images[i];

      try {
        final bytes = await image.readAsBytes();

        if (bytes.isEmpty) {
          throw Exception(
            'La photo ${i + 1} est vide ou invalide.',
          );
        }

        await _databaseService.uploadPhotoSafe(
          appartementId: appartementId,
          bytes: bytes,
          estPrincipale: i == 0,
          ordreAffichage: i,
          titre: 'Photo ${i + 1}',
        );

        onProgress(i + 1, images.length);
      } catch (e) {
        throw Exception(
          'Erreur lors de l\'envoi de la photo ${i + 1} : $e',
        );
      }
    }
  }
}

