import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:admin/data/models/add_appartement/appartement_create.dart';
import 'package:admin/data/models/add_appartement/appartement_info_create.dart';
import 'package:admin/data/models/add_appartement/appartement_role_create.dart';
import 'package:admin/services_appart/add_appartement_service.dart';
import 'package:service/database_service.dart';

import '../widgets/appartement_form_data.dart';


class AjouterAppartementController extends ChangeNotifier {
  final AddAppartementService _service;
  final DatabaseService _databaseService;

  AjouterAppartementController({
    required AddAppartementService service,
    required DatabaseService databaseService,
  })  : _service = service,
        _databaseService = databaseService;

  // ============================================================
  // CALLBACKS UI (injectés par la page)
  // ============================================================

  void Function(String message)? onError;
  void Function(String message)? onInfo;

  // ============================================================
  // ÉTAT
  // ============================================================

  static const int totalSteps = 6;

  final AppartementFormData form = AppartementFormData();

  int _step = 1;
  bool _isSaving = false;

  int get step => _step;
  bool get isSaving => _isSaving;

  // ============================================================
  // CYCLE DE VIE
  // ============================================================

  Future<void> initialize() async {
    await loadResidences();
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  // ============================================================
  // CHARGEMENT DES RÉSIDENCES
  // ============================================================

  Future<void> loadResidences() async {
    form.isLoadingResidences = true;
    notifyListeners();

    try {
      final residences = await _databaseService.getMyResidences();
      form.residences = residences;
    } catch (e, st) {
      debugPrint('❌ Erreur chargement résidences : $e');
      debugPrint('📚 STACK : $st');
      onError?.call(
        'Impossible de charger vos résidences : ${_cleanError(e)}',
      );
    } finally {
      form.isLoadingResidences = false;
      notifyListeners();
    }
  }

// ============================================================
// RÉSIDENCE — SÉLECTION
// ============================================================

  void selectExistingResidence(String? residenceId) {
    if (residenceId == null || residenceId.trim().isEmpty) {
      return;
    }

    final residence =
    form.residences.cast<Map<String, dynamic>?>().firstWhere(
          (item) => item?['id']?.toString() == residenceId,
      orElse: () => null,
    );

    form.selectedResidenceId = residenceId;
    form.isCreatingNewResidence = false;

    if (residence != null) {
      final ville = residence['ville']?.toString().trim() ?? '';
      final adresse = residence['adresse']?.toString().trim() ?? '';
      final localisation =
          residence['localisation']?.toString().trim() ?? '';

      // On mémorise les informations de la résidence.
      form.villeResidenceCtrl.text = ville;
      form.adresseResidenceCtrl.text = adresse;
      form.localisationCtrl.text = localisation;
    }

    notifyListeners();
  }

// ============================================================
// CRÉER UNE NOUVELLE RÉSIDENCE
// ============================================================

  void startCreatingNewResidence() {
    form.isCreatingNewResidence = true;
    form.selectedResidenceId = null;

    // On nettoie uniquement les champs de la résidence.
    form.nomResidenceCtrl.clear();
    form.descriptionResidenceCtrl.clear();
    form.villeResidenceCtrl.clear();
    form.adresseResidenceCtrl.clear();
    form.localisationCtrl.clear();

    notifyListeners();
  }

// ============================================================
// ANNULER LA CRÉATION
// ============================================================

  void cancelCreatingNewResidence() {
    form.isCreatingNewResidence = false;
    form.selectedResidenceId = null;

    form.nomResidenceCtrl.clear();
    form.descriptionResidenceCtrl.clear();
    form.villeResidenceCtrl.clear();
    form.adresseResidenceCtrl.clear();
    form.localisationCtrl.clear();

    notifyListeners();
  }

// ============================================================
// VALIDATION / CRÉATION DE LA RÉSIDENCE
// ============================================================

  Future<String?> _validateAndCreateResidence() async {
    // ----------------------------------------------------------
    // CAS 1 — RÉSIDENCE EXISTANTE
    // ----------------------------------------------------------

    if (!form.isCreatingNewResidence) {
      final residenceId =
      form.selectedResidenceId?.trim();

      if (residenceId == null || residenceId.isEmpty) {
        return 'Veuillez sélectionner une résidence ou en créer une.';
      }

      return null;
    }

    // ----------------------------------------------------------
    // CAS 2 — NOUVELLE RÉSIDENCE
    // ----------------------------------------------------------

    final nom =
    form.nomResidenceCtrl.text.trim();

    final description =
    form.descriptionResidenceCtrl.text.trim();

    final ville =
    form.villeResidenceCtrl.text.trim();

    final adresse =
    form.adresseResidenceCtrl.text.trim();

    final localisation =
    form.localisationCtrl.text.trim();

    if (nom.isEmpty) {
      return 'Veuillez saisir le nom de la résidence.';
    }

    if (ville.isEmpty) {
      return 'Veuillez saisir la ville de la résidence.';
    }

    if (adresse.isEmpty) {
      return 'Veuillez saisir l\'adresse de la résidence.';
    }

    if (localisation.isEmpty) {
      return 'Veuillez saisir la localisation de la résidence.';
    }

    _isSaving = true;
    notifyListeners();

    try {
      final residenceId =
      await _databaseService.createResidence(
        nom: nom,
        description:
        description.isEmpty ? null : description,
        ville: ville,
        adresse: adresse,

        // IMPORTANT :
        // Ce paramètre doit être ajouté à
        // DatabaseService.createResidence().
        localisation: localisation,
      );

      form.selectedResidenceId = residenceId;
      form.isCreatingNewResidence = false;

      // Recharger les résidences pour que la nouvelle
      // résidence apparaisse immédiatement dans le sélecteur.
      await loadResidences();

      // On resélectionne explicitement la résidence créée.
      form.selectedResidenceId = residenceId;

      onInfo?.call(
        'Résidence créée avec succès.',
      );

      return null;
    } catch (e, st) {
      debugPrint(
        '❌ Erreur création résidence : $e',
      );

      debugPrint(
        '📚 STACK : $st',
      );

      return 'Impossible de créer la résidence : '
          '${_cleanError(e)}';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ============================================================
  // ÉTAPE 1 — INFORMATIONS : setters
  // ============================================================

  void setType(String type) {
    form.type = type;
    notifyListeners();
  }

  void setDureeSejour(String duree) {
    form.dureeSejour = duree;
    notifyListeners();
  }

  // ============================================================
  // ÉTAPE 2 — DÉTAILS
  // ============================================================

  void setDateDisponibilite(DateTime date) {
    form.dateDisponibilite = date;
    notifyListeners();
  }

  // ============================================================
  // ÉTAPE 3 — CARACTÉRISTIQUES
  // ============================================================

  void setServiceInclus(bool v) {
    form.serviceInclus = v;
    notifyListeners();
  }

  void setInternet(bool v) {
    form.internet = v;
    notifyListeners();
  }

  void setStationnement(bool v) {
    form.stationnement = v;
    notifyListeners();
  }

  void setMeuble(bool v) {
    form.meuble = v;
    notifyListeners();
  }

  void setClimatisation(bool v) {
    form.climatisation = v;
    notifyListeners();
  }

  // ============================================================
  // ÉTAPE 4 — ÉQUIPEMENTS
  // ============================================================

  void toggleEquipement(String key) {
    if (!form.equipements.containsKey(key)) return;
    form.equipements[key] = !form.equipements[key]!;
    notifyListeners();
  }

  int get nombreEquipementsSelectionnes =>
      form.equipements.values.where((v) => v).length;

  // ============================================================
  // PHOTOS
  // ============================================================

  Future<void> pickImages() async {
    try {
      final images = await ImagePicker().pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (images.isEmpty) return;
      form.selectedImages.addAll(images);
      notifyListeners();
    } catch (e) {
      onError?.call('Erreur lors de la sélection des photos : $e');
    }
  }

  void removeImage(int index) {
    if (index < 0 || index >= form.selectedImages.length) return;
    form.selectedImages.removeAt(index);
    notifyListeners();
  }

  void clearImages() {
    form.selectedImages.clear();
    notifyListeners();
  }

  // ============================================================
  // ÉTAPE 5 — RÈGLES
  // ============================================================

  void setHeureArrivee(TimeOfDay t) {
    form.heureArrivee = t;
    notifyListeners();
  }

  void setHeureDepart(TimeOfDay t) {
    form.heureDepart = t;
    notifyListeners();
  }

  void setFumeur(bool v) {
    form.fumeur = v;
    notifyListeners();
  }

  void setAnimauxAcceptes(bool v) {
    form.animauxAcceptes = v;

    // Si on désactive "Animaux acceptés",
    // aucun animal ne doit rester sélectionné.
    if (!v) {
      form.animauxChien = false;
      form.animauxChat = false;
    }

    notifyListeners();
  }

  void setAnimauxChien(bool v) {
    form.animauxChien = v;

    // Chien et Chat sont exclusifs.
    if (v) {
      form.animauxChat = false;
    }

    notifyListeners();
  }

  void setAnimauxChat(bool v) {
    form.animauxChat = v;

    // Chien et Chat sont exclusifs.
    if (v) {
      form.animauxChien = false;
    }

    notifyListeners();
  }

  void setFetes(bool v) {
    form.fetes = v;
    notifyListeners();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  Future<void> nextStep() async {
    if (_isSaving) return;

    switch (_step) {
    // --------------------------------------------------------
    // Étape 1 → Résidence
    // --------------------------------------------------------
      case 1:
        final String? err = await _validateAndCreateResidence();
        if (err != null) {
          onError?.call(err);
          return;
        }
        _step = 2;
        break;

    // --------------------------------------------------------
    // Étape 2 → Infos générales
    // --------------------------------------------------------
      case 2:
        final String? err = _validateInfos();
        if (err != null) {
          onError?.call(err);
          return;
        }
        _step = 3;
        break;

    // --------------------------------------------------------
    // Étape 3 → Détails
    // --------------------------------------------------------
      case 3:
        final String? err = _validateDetails();
        if (err != null) {
          onError?.call(err);
          return;
        }
        _step = 4;
        break;

    // --------------------------------------------------------
    // Étape 4 → Caractéristiques
    // --------------------------------------------------------
      case 4:
        final String? err = _validateCaracteristiques();
        if (err != null) {
          onError?.call(err);
          return;
        }
        _step = 5;
        break;

    // --------------------------------------------------------
    // Étape 5 → Équipements (pas de validation)
    // --------------------------------------------------------
      case 5:
        _step = 6;
        break;

    // --------------------------------------------------------
    // Étape 6 → Règles → soumission
    // --------------------------------------------------------
      case 6:
        final String? err = _validateRegles();
        if (err != null) {
          onError?.call(err);
          return;
        }
        await _soumettre();
        return; // pas de notifyListeners ici, _soumettre gère
    }

    notifyListeners();
  }

  void previousStep() {
    if (_step <= 1 || _isSaving) return;
    _step--;
    notifyListeners();
  }

  void goToStep(int step) {
    if (step < 1 || step > totalSteps || _isSaving) return;
    _step = step;
    notifyListeners();
  }

  // ============================================================
  // VALIDATIONS (retournent un message d'erreur OU null)
  // ============================================================

  String? _validateInfos() {
    if (form.nomAppartementCtrl.text.trim().isEmpty) {
      return 'Veuillez saisir le nom de l\'appartement.';
    }
    final cleanPrice = form.prixCtrl.text.replaceAll(RegExp(r'\s'), '');
    final prix = double.tryParse(cleanPrice) ?? 0.0;
    if (prix <= 0) {
      return 'Veuillez saisir un prix valide.';
    }
    return null;
  }

  String? _validateDetails() {
    if (form.descriptionCtrl.text.trim().isEmpty) {
      return 'Veuillez saisir une description du bien.';
    }
    if (form.dateDisponibilite == null) {
      return 'Veuillez sélectionner une date de disponibilité.';
    }
    return null;
  }

  String? _validateCaracteristiques() {
    final chambres = int.tryParse(form.chambreCtrl.text.trim()) ?? -1;
    final salons = int.tryParse(form.salonCtrl.text.trim()) ?? -1;
    final douches = int.tryParse(form.doucheCtrl.text.trim()) ?? -1;
    final cuisines = int.tryParse(form.cuisineCtrl.text.trim()) ?? -1;
    final etage = int.tryParse(form.etageCtrl.text.trim()) ?? -1;
    final taille =
        double.tryParse(form.tailleCtrl.text.trim().replaceAll(',', '.')) ??
            -1;

    if (chambres < 0) {
      return 'Le nombre de chambres doit être supérieur ou égal à 0.';
    }
    if (salons < 0) {
      return 'Le nombre de salons doit être supérieur ou égal à 0.';
    }
    if (douches < 0) {
      return 'Le nombre de salles de bain doit être supérieur ou égal à 0.';
    }
    if (cuisines < 0) {
      return 'Le nombre de cuisines doit être supérieur ou égal à 0.';
    }
    if (etage < 0) {
      return 'L\'étage doit être supérieur ou égal à 0.';
    }
    if (taille <= 0) {
      return 'La taille doit être supérieure à 0 m².';
    }
    return null;
  }

  String? _validateRegles() {
    if (form.descriptionRegleCtrl.text.trim().isEmpty) {
      return 'Veuillez saisir les règles du séjour.';
    }
    final nombreClient =
        int.tryParse(form.nombreClientCtrl.text.trim()) ?? 0;
    if (nombreClient < 1) {
      return 'Le nombre maximum de clients doit être supérieur ou égal à 1.';
    }
    return null;
  }


  // ============================================================
  // SOUMISSION FINALE
  // ============================================================

  Future<void> _soumettre() async {
    final String? residenceId = form.selectedResidenceId?.trim();
    if (residenceId == null || residenceId.isEmpty) {
      onError?.call('Aucune résidence valide n\'est sélectionnée.');
      _step = 1;
      notifyListeners();
      return;
    }

    _isSaving = true;
    notifyListeners();

    try {
      // ------------------------------------------------------
      // Prix
      // ------------------------------------------------------
      final cleanPrice = form.prixCtrl.text.replaceAll(RegExp(r'\s'), '');
      final prix = double.tryParse(cleanPrice) ?? 0.0;
      if (prix <= 0) {
        throw Exception('Veuillez saisir un prix valide.');
      }

      // ------------------------------------------------------
      // 1. Appartement
      // ------------------------------------------------------
      final appartement = AppartementCreate(
        titre: form.nomAppartementCtrl.text.trim(),
        adresse: form.adresseCtrl.text.trim(),
        ville: form.villeCtrl.text.trim(),
        type: form.type,
        prix: prix,
        description: form.descriptionCtrl.text.trim(),
        nbreSejour: form.dureeSejour,
        equipements: form.equipements,
        residenceId: residenceId,
      );

      final appartementId = await _service.createAppartement(appartement);
      debugPrint('✅ Appartement créé : $appartementId');

      // ------------------------------------------------------
      // 2. Infos
      // ------------------------------------------------------
      final info = AppartementInfoCreate(
        chambre: int.tryParse(form.chambreCtrl.text.trim()) ?? 0,
        salon: int.tryParse(form.salonCtrl.text.trim()) ?? 0,
        douche: int.tryParse(form.doucheCtrl.text.trim()) ?? 0,
        cuisine: int.tryParse(form.cuisineCtrl.text.trim()) ?? 0,
        etage: int.tryParse(form.etageCtrl.text.trim()) ?? 0,
        taille: double.tryParse(
          form.tailleCtrl.text.trim().replaceAll(',', '.'),
        ) ??
            0.0,
        serviceInclus: form.serviceInclus,
        internet: form.internet,
        stationnement: form.stationnement,
        meuble: form.meuble,
        climatisation: form.climatisation,
      );

      await _service.insertAppartementInfo(appartementId, info);
      debugPrint('✅ Informations insérées');

      // ------------------------------------------------------
      // 3. Règles
      // ------------------------------------------------------
      String valeurAnimaux = 'Pas d animaux';

      if (form.animauxAcceptes) {
        if (form.animauxChien) {
          valeurAnimaux = 'Animaux acceptés: Chien';
        } else if (form.animauxChat) {
          valeurAnimaux = 'Animaux acceptés: Chat';
        }
      }

      final role = AppartementRoleCreate(
        description: form.descriptionRegleCtrl.text.trim(),
        heureArrive: form.heureArrivee,
        heureDepart: form.heureDepart,
        nombreClient: int.tryParse(form.nombreClientCtrl.text.trim()) ?? 1,
        fete: form.fetes ? 'Fêtes acceptées' : 'Pas de fêtes',
        animaux: valeurAnimaux,
        fumeur: form.fumeur ? 'Fumeurs acceptés' : 'Fumeurs non acceptés',
      );

      await _service.insertAppartementRole(appartementId, role);
      debugPrint('✅ Règles insérées');

      // ------------------------------------------------------
      // 4. Disponibilités
      // ------------------------------------------------------
      if (form.dateDisponibilite != null) {
        final dateFin =
        form.dateDisponibilite!.add(const Duration(days: 30));
        await _service.createDisponibilites(
          appartementId,
          form.dateDisponibilite!,
          dateFin,
        );
        debugPrint('✅ Disponibilités créées');
      }

      // ------------------------------------------------------
      // 5. Photos
      // ------------------------------------------------------
      if (form.selectedImages.isNotEmpty) {
        await _service.uploadPhotos(
          appartementId,
          form.selectedImages.cast<XFile>(),
              (current, total) {
            debugPrint('📷 Upload photos : $current/$total');
          },
        );
        debugPrint('✅ Photos uploadées');
      }

      // ------------------------------------------------------
      // Succès
      // ------------------------------------------------------
      onInfo?.call(
        'Votre bien a bien été enregistré. '
            'Il sera vérifié par notre équipe avant sa publication.',
      );
      onSuccess?.call();
    } catch (e, st) {
      debugPrint('❌ ERREUR soumission : $e');
      debugPrint('📚 STACK : $st');
      onError?.call('Erreur : ${_cleanError(e)}');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Callback appelé après une soumission réussie (navigation).
  void Function()? onSuccess;

  // ============================================================
  // UTIL
  // ============================================================

  String _cleanError(Object e) {
    return e.toString().replaceFirst('Exception:', '').trim();
  }
}