import 'package:flutter/material.dart';

/// Regroupe tout l'état du formulaire d'ajout d'appartement.
///
/// Ce modèle est purement data : pas de logique métier ici.
/// Le controller (ChangeNotifier) le détient et le fait muter.
class AppartementFormData {
  // ============================================================
  // RÉSIDENCE
  // ============================================================

  String? selectedResidenceId;

  bool isCreatingNewResidence = false;

  List<Map<String, dynamic>> residences = [];

  bool isLoadingResidences = true;

  // ------------------------------------------------------------
  // INFORMATIONS DE LA RÉSIDENCE
  // ------------------------------------------------------------

  final TextEditingController nomResidenceCtrl =
  TextEditingController();

  final TextEditingController descriptionResidenceCtrl =
  TextEditingController();

  final TextEditingController villeResidenceCtrl =
  TextEditingController();

  final TextEditingController adresseResidenceCtrl =
  TextEditingController();

  final TextEditingController localisationCtrl =
  TextEditingController();

  // ============================================================
  // ÉTAPE 2 — INFORMATIONS DE L'APPARTEMENT
  // ============================================================

  String type = 'studio';

  String dureeSejour = 'nuit';

  final TextEditingController nomAppartementCtrl =
  TextEditingController();

  final TextEditingController adresseCtrl =
  TextEditingController();

  final TextEditingController villeCtrl =
  TextEditingController();

  final TextEditingController prixCtrl =
  TextEditingController();

  final TextEditingController descriptionCtrl =
  TextEditingController();

  // ============================================================
  // ÉTAPE 3 — DÉTAILS
  // ============================================================

  DateTime? dateDisponibilite;

  // ============================================================
  // ÉTAPE 4 — CARACTÉRISTIQUES
  // ============================================================

  final TextEditingController chambreCtrl =
  TextEditingController();

  final TextEditingController salonCtrl =
  TextEditingController();

  final TextEditingController doucheCtrl =
  TextEditingController();

  final TextEditingController cuisineCtrl =
  TextEditingController();

  final TextEditingController etageCtrl =
  TextEditingController();

  final TextEditingController tailleCtrl =
  TextEditingController();

  bool serviceInclus = false;
  bool internet = false;
  bool stationnement = false;
  bool meuble = false;
  bool climatisation = false;

  // ============================================================
  // ÉTAPE 5 — ÉQUIPEMENTS
  // ============================================================

  final Map<String, bool> equipements = {
    'piscine': false,
    'ascenseur': false,
    'baignoire': false,
    'seche_cheveux': false,
    'produits_nettoyage': false,
    'shampooing': false,
    'savon_corps': false,
    'eau_chaude': false,
    'gel_douche': false,
    'laveuse_gratuite': false,
    'secheuse_gratuite': false,
    'serviettes_draps': false,
    'cintres': false,
    'fer_repasser': false,
    'sechoir_vetements': false,
    'cuisine': false,
    'refrigerateur': false,
    'micro_ondes': false,
    'bases_cuisine': false,
    'plats_argenterie': false,
    'congelateur': false,
    'lave_vaisselle': false,
    'cuisiniere_gaz': false,
    'four': false,
    'bouilloire': false,
    'cafetiere': false,
    'verres_vin': false,
    'grille_pain': false,
    'mixeur': false,
    'table_manger': false,
    'serrure_chambre': false,
    'camera_exterieure': false,
    'alarme_monoxyde_carbone': false,
    'television': false,
  };

  /// Ordre d'affichage des équipements
  /// clé interne → label français.
  static const Map<String, String> equipementsLabels = {
    'piscine': 'Piscine',
    'ascenseur': 'Ascenseur',
    'baignoire': 'Baignoire',
    'seche_cheveux': 'Sèche-cheveux',
    'produits_nettoyage': 'Produits de nettoyage',
    'shampooing': 'Shampooing',
    'savon_corps': 'Savon corps',
    'eau_chaude': 'Eau chaude',
    'gel_douche': 'Gel douche',
    'laveuse_gratuite': 'Laveuse gratuite',
    'secheuse_gratuite': 'Sècheuse gratuite',
    'serviettes_draps': 'Serviettes et draps',
    'cintres': 'Cintres',
    'fer_repasser': 'Fer à repasser',
    'sechoir_vetements': 'Séchoir à vêtements',
    'cuisine': 'Cuisine',
    'refrigerateur': 'Réfrigérateur',
    'micro_ondes': 'Micro-ondes',
    'bases_cuisine': 'Bases de cuisine',
    'plats_argenterie': 'Plats et argenterie',
    'congelateur': 'Congélateur',
    'lave_vaisselle': 'Lave-vaisselle',
    'cuisiniere_gaz': 'Cuisinière à gaz',
    'four': 'Four',
    'bouilloire': 'Bouilloire',
    'cafetiere': 'Cafetière',
    'verres_vin': 'Verres à vin',
    'grille_pain': 'Grille-pain',
    'mixeur': 'Mixeur',
    'table_manger': 'Table à manger',
    'serrure_chambre': 'Serrure de chambre',
    'camera_exterieure': 'Caméra extérieure',
    'alarme_monoxyde_carbone': 'Alarme monoxyde de carbone',
    'television': 'Télévision',
  };

  // ============================================================
  // PHOTOS
  // ============================================================

  final List<dynamic> selectedImages = [];

  // ============================================================
  // ÉTAPE 6 — RÈGLES
  // ============================================================

  final TextEditingController descriptionRegleCtrl =
  TextEditingController();

  final TextEditingController nombreClientCtrl =
  TextEditingController(text: '1');

  TimeOfDay heureArrivee =
  const TimeOfDay(hour: 14, minute: 0);

  TimeOfDay heureDepart =
  const TimeOfDay(hour: 12, minute: 0);

  bool fumeur = false;

  bool animauxAcceptes = false;

  bool animauxChien = false;

  bool animauxChat = false;

  bool fetes = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    // Résidence
    nomResidenceCtrl.dispose();
    descriptionResidenceCtrl.dispose();
    villeResidenceCtrl.dispose();
    adresseResidenceCtrl.dispose();
    localisationCtrl.dispose();

    // Appartement
    nomAppartementCtrl.dispose();
    adresseCtrl.dispose();
    villeCtrl.dispose();
    prixCtrl.dispose();
    descriptionCtrl.dispose();

    // Caractéristiques
    chambreCtrl.dispose();
    salonCtrl.dispose();
    doucheCtrl.dispose();
    cuisineCtrl.dispose();
    etageCtrl.dispose();
    tailleCtrl.dispose();

    // Règles
    descriptionRegleCtrl.dispose();
    nombreClientCtrl.dispose();
  }
}