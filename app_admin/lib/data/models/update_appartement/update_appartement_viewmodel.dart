import 'package:flutter/material.dart';
import 'package:service/database_service.dart';


// VIEWMODEL : MODIFICATION APPARTEMENT
class UpdateAppartementViewModel extends ChangeNotifier {

  // SERVICE DATABASE
  final DatabaseService db = DatabaseService();


  // FORMULAIRE
  final GlobalKey<FormState> formKey =
  GlobalKey<FormState>();


  //SECTION RÉSIDENCE

  //Liste des résidences appartenant au propriétaire.
  List<Map<String, dynamic>> _residences = [];

  List<Map<String, dynamic>> get residences =>
      List.unmodifiable(_residences);

  //ID de la résidence actuellement sélectionnée.
  String? _selectedResidenceId;

  String? get selectedResidenceId =>
      _selectedResidenceId;

  //Nom de la résidence.
  String _selectedResidenceName = '';

  String get selectedResidenceName =>
      _selectedResidenceName;

  //Ville de la résidence.
  String _selectedResidenceVille = '';

  String get selectedResidenceVille =>
      _selectedResidenceVille;

  //Adresse de la résidence.
  String _selectedResidenceAdresse = '';

  String get selectedResidenceAdresse =>
      _selectedResidenceAdresse;

  //URL Google Maps localisation.
  String _selectedResidenceLocalisation = '';

  String get selectedResidenceLocalisation =>
      _selectedResidenceLocalisation;

  //Sélection d'une résidence.
  void setResidence({
    required String residenceId,
    String? nom,
    String? ville,
    String? adresse,
    String? localisation,
  }) {
    final id = residenceId.trim();

    if (id.isEmpty) {
      return;
    }

    _selectedResidenceId = id;

    _selectedResidenceName =
        nom?.trim() ?? '';

    _selectedResidenceVille =
        ville?.trim() ?? '';

    _selectedResidenceAdresse =
        adresse?.trim() ?? '';

    _selectedResidenceLocalisation =
        localisation?.trim() ?? '';

    notifyListeners();
  }

  //Réinitialise la résidence sélectionnée.
  void clearResidence() {
    _selectedResidenceId = null;
    _selectedResidenceName = '';
    _selectedResidenceVille = '';
    _selectedResidenceAdresse = '';
    _selectedResidenceLocalisation = '';

    notifyListeners();
  }

  //SECTION INFORMATIONS
  final TextEditingController titreCtrl =
  TextEditingController();

  final TextEditingController prixController =
  TextEditingController();

  final TextEditingController descriptionCtrl =
  TextEditingController();

  final TextEditingController typeCtrl =
  TextEditingController();

  final TextEditingController nbreSejourCtrl =
  TextEditingController();

  //Modification du type depuis InformationSection.
  void setType(String? value) {
    typeCtrl.text = value ?? '';
    notifyListeners();
  }

  //Modification du nombre de séjour depuis InformationSection.
  void setNbreSejour(String? value) {
    nbreSejourCtrl.text = value ?? '';
    notifyListeners();
  }


  //SECTION CARACTÉRISTIQUES
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


  // OPTIONS CARACTÉRISTIQUES
  bool _serviceInclus = false;

  bool get serviceInclus =>
      _serviceInclus;

  set serviceInclus(bool value) {
    _serviceInclus = value;
    notifyListeners();
  }

  void setServiceInclus(bool value) {
    serviceInclus = value;
  }

  bool _internet = false;

  bool get internet =>
      _internet;

  set internet(bool value) {
    _internet = value;
    notifyListeners();
  }

  void setInternet(bool value) {
    internet = value;
  }

  bool _stationnement = false;

  bool get stationnement => _stationnement;

  set stationnement(bool value) {
    _stationnement = value;
    notifyListeners();
  }

  void setStationnement(bool value) {
    stationnement = value;
  }

  bool _meuble = false;

  bool get meuble => _meuble;

  set meuble(bool value) {
    _meuble = value;
    notifyListeners();
  }

  void setMeuble(bool value) {
    meuble = value;
  }

  bool _climatisation = false;

  bool get climatisation => _climatisation;

  set climatisation(bool value) {
    _climatisation = value;
    notifyListeners();
  }

  void setClimatisation(bool value) {
    climatisation = value;
  }

  //SECTION DISPONIBILITÉS
  final TextEditingController dateDebutCtrl =
  TextEditingController();

  final TextEditingController dateFinCtrl =
  TextEditingController();

  //SECTION RÈGLES
  final TextEditingController descriptionRegleCtrl = TextEditingController();

  final TextEditingController heureArriveeCtrl = TextEditingController();

  final TextEditingController heureDepartCtrl = TextEditingController();

  final TextEditingController nbreClientCtrl = TextEditingController();

  //RÈGLES : FUMEUR
  String _selectedFumeur = 'Fumeurs non acceptés';

  String get selectedFumeur => _selectedFumeur;

  void setSelectedFumeur(String? value) {
    if (value == null) return;

    _selectedFumeur = value;
    notifyListeners();
  }

  // RÈGLES : ANIMAUX
  String _selectedAnimaux = 'Pas d animaux';

  String get selectedAnimaux => _selectedAnimaux;

  void setSelectedAnimaux(String? value) {
    if (value == null) return;

    _selectedAnimaux = value;
    notifyListeners();
  }

  //RÈGLES : FÊTES
  String _selectedFete = 'Pas de fêtes';

  String get selectedFete => _selectedFete;

  void setSelectedFete(String? value) {
    if (value == null) return;

    _selectedFete = value;
    notifyListeners();
  }

  //SECTION ÉQUIPEMENTS
  Map<String, bool> _equipements = {};

  Map<String, bool> get equipements =>
      Map.unmodifiable(_equipements);

  void toggleEquipement(
      String key,
      bool value,
      ) {
    _equipements[key] = value;
    notifyListeners();
  }

  //ÉTAT GÉNÉRAL
  UpdateAppartementState _state =
  const UpdateAppartementState(
    isLoading: true,
  );

  UpdateAppartementState get state => _state;


  // CONSTRUCTEUR
  UpdateAppartementViewModel({
    required Map<String, dynamic> appartementData,
  }) {
    _initialize(appartementData);
  }


  // INITIALISATION
  Future<void> _initialize(
      Map<String, dynamic> data,
      ) async {
    _state = _state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    notifyListeners();

    try {

      //Charger les données de l'appartement
      _loadData(data);

      //Charger les résidences du propriétaire
      await _loadResidences();

      //Initialisation terminée
      _state = _state.copyWith(
        isLoading: false,
        dataLoaded: true,
        errorMessage: null,
      );

      notifyListeners();
    } catch (e) {
      debugPrint(
        '_initialize UpdateAppartementViewModel: $e',
      );

      _state = _state.copyWith(
        isLoading: false,
        dataLoaded: false,
        errorMessage: e.toString(),
      );

      notifyListeners();
    }
  }


  // CHARGEMENT DES RÉSIDENCES
  Future<void> _loadResidences() async {
    try {

      final result = await db.getMyResidences();

      _residences = result
          .map(
            (residence) =>
        Map<String, dynamic>.from(residence),
      )
          .toList();

      // Vérifier que la résidence actuellement liée à l'appartement existe dans la liste.
      if (_selectedResidenceId != null &&
          _selectedResidenceId!.trim().isNotEmpty) {
        final currentResidence =
        _residences.firstWhere(
              (residence) =>
          residence['id']?.toString() ==
              _selectedResidenceId,
          orElse: () => <String, dynamic>{},
        );

        if (currentResidence.isNotEmpty) {
          _selectedResidenceName =
              currentResidence['nom']?.toString() ?? '';

          _selectedResidenceVille = currentResidence['ville']?.toString() ?? '';

          _selectedResidenceAdresse = currentResidence['adresse']?.toString() ?? '';

          _selectedResidenceLocalisation = currentResidence['localisation']?.toString() ?? '';
        }
      }
    } catch (e) {
      debugPrint(
        '_loadResidences: $e',
      );

      _residences = [];

      // On conserve l'erreur dans l'état.
      _state = _state.copyWith(
        errorMessage: e.toString(),
      );
    }

    notifyListeners();
  }


  // CHARGEMENT DES DONNÉES APPARTEMENT
  void _loadData(
      Map<String, dynamic> data,
      ) {

    //RÉSIDENCE
    final residenceId =
    data['residence_id']?.toString();

    final residenceData =
        data['residences'] ??
            data['residence'] ??
            {};

    if (residenceId != null &&
        residenceId.trim().isNotEmpty) {
      _selectedResidenceId = residenceId.trim();

      if (residenceData is Map) {
        _selectedResidenceName = residenceData['nom']?.toString() ?? '';

        _selectedResidenceVille = residenceData['ville']?.toString() ?? '';

        _selectedResidenceAdresse = residenceData['adresse']?.toString() ?? '';

        _selectedResidenceLocalisation =
            residenceData['localisation']?.toString() ?? '';
      }
    }


    //INFORMATIONS APPARTEMENT
    titreCtrl.text = data['titre']?.toString() ?? '';

    prixController.text = data['prix']?.toString() ?? '';

    descriptionCtrl.text = data['description']?.toString() ?? '';

    typeCtrl.text = data['type']?.toString() ?? '';

    nbreSejourCtrl.text = data['nbre_sejour']?.toString() ?? '';


    //CARACTÉRISTIQUES
    final infoRaw =
    data['appartement_infos'];

    final Map<String, dynamic> info =
    infoRaw is Map
        ? Map<String, dynamic>.from(infoRaw)
        : {};

    chambreCtrl.text = info['chambre']?.toString() ?? '';

    salonCtrl.text = info['salon']?.toString() ?? '';

    doucheCtrl.text = info['douche']?.toString() ?? '';

    cuisineCtrl.text = info['cuisine']?.toString() ?? '';

    etageCtrl.text = info['etage']?.toString() ?? '';

    tailleCtrl.text = info['taille']?.toString() ?? '';

    _serviceInclus = info['service_inclus'] == 'Oui';

    _internet = info['internet'] == 'Oui';

    _stationnement = info['stationnement'] == 'Oui';

    _meuble = info['meuble'] == 'Oui';

    _climatisation = info['climatisation'] == 'Oui';


    //DISPONIBILITÉS
    final dispoRaw =
    data['disponibilite'];

    final Map<String, dynamic> dispo =
    dispoRaw is Map
        ? Map<String, dynamic>.from(dispoRaw)
        : {};

    dateDebutCtrl.text = dispo['date_debut']?.toString() ?? '';

    dateFinCtrl.text = dispo['date_fin']?.toString() ?? '';

    //RÈGLES
    final roleRaw =
    data['appartement_role'];

    final Map<String, dynamic> role =
    roleRaw is Map
        ? Map<String, dynamic>.from(roleRaw)
        : {};

    descriptionRegleCtrl.text = role['description']?.toString() ?? '';

    heureArriveeCtrl.text = role['heure_arrive']?.toString() ?? '';

    heureDepartCtrl.text = role['heure_depart']?.toString() ?? '';

    nbreClientCtrl.text = role['nombre_client']?.toString() ?? '';

    _selectedFumeur = role['fumeur']?.toString() ?? 'Fumeurs non acceptés';

    _selectedAnimaux = role['animaux']?.toString() ?? 'Pas d animaux';

    _selectedFete = role['fete']?.toString() ?? 'Pas de fêtes';

    //ÉQUIPEMENTS
    final equipementsRaw =
    data['autres_equipements'];

    if (equipementsRaw is Map) {
      _equipements =
          equipementsRaw.map(
                (key, value) => MapEntry(
              key.toString(),
              value == true,
            ),
          );
    } else {
      _equipements = {};
    }

    // DONNÉES INITIALES
    _state = _state.copyWith(
      initialData: data,
      dataLoaded: true,
      errorMessage: null,
    );
  }


  // VALIDATEURS
  String? validateRequired(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Ce champ est requis';
    }

    return null;
  }

  String? validateResidence(
      String? value,
      ) {
    if (_selectedResidenceId == null ||
        _selectedResidenceId!.trim().isEmpty) {
      return 'Veuillez sélectionner une résidence';
    }

    return null;
  }


  String? validatePrix(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Le prix est requis';
    }

    final prix = double.tryParse(value.trim());

    if (prix == null) {
      return 'Entrez un nombre valide';
    }

    if (prix < 0) {
      return 'Le prix ne peut pas être négatif';
    }

    return null;
  }

  String? validateDescription(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'La description est requise';
    }

    if (value.trim().length < 20) {
      return 'Minimum 20 caractères';
    }

    return null;
  }

  // UTILITAIRE : HH:MM → TimeOfDay
  TimeOfDay? parseTimeOfDay(
      String text,
      ) {
    final value = text.trim();

    if (value.isEmpty) {
      return null;
    }

    final parts = value.split(':');

    if (parts.length != 2) {
      return null;
    }

    final hour =
    int.tryParse(parts[0]);

    final minute =
    int.tryParse(parts[1]);

    if (hour == null ||
        minute == null) {
      return null;
    }

    if (hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    return TimeOfDay(
      hour: hour,
      minute: minute,
    );
  }


  // MISE À JOUR
  Future<bool> updateAppartement() async {
    _state = _state.copyWith(
      isSaving: true,
      errorMessage: null,
    );

    notifyListeners();

    try {

      // VÉRIFICATION RÉSIDENCE
      final residenceId =
          _selectedResidenceId;

      if (residenceId == null ||
          residenceId.trim().isEmpty) {
        throw Exception(
          'Veuillez sélectionner une résidence.',
        );
      }


      // ID APPARTEMENT
      final appartementId =
      _state.initialData?['id']
          ?.toString();

      if (appartementId == null ||
          appartementId.trim().isEmpty) {
        throw Exception(
          'ID appartement manquant.',
        );
      }

      //APPARTEMENT
      await db.updateAppartement(
        appartementId: appartementId,
        residenceId: residenceId,
        titre: titreCtrl.text.trim(),
        description:
        descriptionCtrl.text.trim(),
        prix:
        double.tryParse(
          prixController.text.trim(),
        ) ??
            0,
        type:
        typeCtrl.text.trim(),
        nbreSejour:
        nbreSejourCtrl.text.trim(),
        equipements:
        _equipements,
      );

      //INFORMATIONS CARACTÉRISTIQUES
      final infoRaw =
      _state.initialData?[
      'appartement_infos'];

      final infoId =
      infoRaw is Map
          ? infoRaw['id']?.toString() ?? ''
          : '';

      if (infoId.isNotEmpty) {
        await db.updateAppartementInfo(
          infoId: infoId,
          chambre:
          int.tryParse(
            chambreCtrl.text.trim(),
          ) ??
              0,
          salon:
          int.tryParse(
            salonCtrl.text.trim(),
          ) ??
              0,
          douche:
          int.tryParse(
            doucheCtrl.text.trim(),
          ) ??
              0,
          cuisine:
          int.tryParse(
            cuisineCtrl.text.trim(),
          ) ??
              0,
          etage:
          int.tryParse(
            etageCtrl.text.trim(),
          ) ??
              0,
          taille:
          double.tryParse(
            tailleCtrl.text.trim(),
          ) ??
              0.0,
          serviceInclus:
          _serviceInclus
              ? 'Oui'
              : 'Non',
          internet:
          _internet
              ? 'Oui'
              : 'Non',
          stationnement:
          _stationnement
              ? 'Oui'
              : 'Non',
          meuble:
          _meuble
              ? 'Oui'
              : 'Non',
          climatisation:
          _climatisation
              ? 'Oui'
              : 'Non',
        );
      }

      //RÈGLES
      final roleRaw =
      _state.initialData?[
      'appartement_role'];

      final roleId =
      roleRaw is Map
          ? roleRaw['id']?.toString() ?? ''
          : '';

      if (roleId.isNotEmpty) {
        final heureArrive =
        parseTimeOfDay(
          heureArriveeCtrl.text,
        );

        final heureDepart =
        parseTimeOfDay(
          heureDepartCtrl.text,
        );

        await db.updateAppartementRole(
          roleId: roleId,
          description:
          descriptionRegleCtrl.text.trim(),
          heureArrive:
          heureArrive ??
              const TimeOfDay(
                hour: 14,
                minute: 0,
              ),
          heureDepart:
          heureDepart ??
              const TimeOfDay(
                hour: 12,
                minute: 0,
              ),
          nombreClient:
          int.tryParse(
            nbreClientCtrl.text.trim(),
          ) ??
              1,
          fete:
          _selectedFete,
          animaux:
          _selectedAnimaux,
          fumeur:
          _selectedFumeur,
        );
      }

      //DISPONIBILITÉS
      final dispoRaw =
      _state.initialData?[
      'disponibilite'];

      final dispoId =
      dispoRaw is Map
          ? dispoRaw['id']?.toString() ?? ''
          : '';

      if (dispoId.isNotEmpty) {
        final dateDebut =
        DateTime.tryParse(
          dateDebutCtrl.text.trim(),
        );

        final dateFin =
        DateTime.tryParse(
          dateFinCtrl.text.trim(),
        );

        if (dateDebut != null &&
            dateFin != null) {
          if (dateFin.isBefore(
            dateDebut,
          )) {
            throw Exception(
              'La date de fin doit être après la date de début.',
            );
          }

          await db.updateDisponibilite(
            disponibiliteId: dispoId,
            dateDebut: dateDebut,
            dateFin: dateFin,
          );
        }
      }

      // SUCCÈS
      _state = _state.copyWith(
        isSaving: false,
        errorMessage: null,
      );

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(
        'updateAppartement: $e',
      );

      _state = _state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
      );

      notifyListeners();

      return false;
    }
  }


  // NETTOYAGE
  @override
  void dispose() {
    // Informations
    titreCtrl.dispose();
    prixController.dispose();
    descriptionCtrl.dispose();
    typeCtrl.dispose();
    nbreSejourCtrl.dispose();

    // Caractéristiques
    chambreCtrl.dispose();
    salonCtrl.dispose();
    doucheCtrl.dispose();
    cuisineCtrl.dispose();
    etageCtrl.dispose();
    tailleCtrl.dispose();

    // Disponibilités
    dateDebutCtrl.dispose();
    dateFinCtrl.dispose();

    // Règles
    descriptionRegleCtrl.dispose();
    heureArriveeCtrl.dispose();
    heureDepartCtrl.dispose();
    nbreClientCtrl.dispose();

    super.dispose();
  }
}


  // STATE
class UpdateAppartementState {
  final bool isLoading;
  final bool isSaving;
  final bool dataLoaded;
  final String? errorMessage;
  final Map<String, dynamic>? initialData;

  const UpdateAppartementState({
    this.isLoading = false,
    this.isSaving = false,
    this.dataLoaded = false,
    this.errorMessage,
    this.initialData,
  });

  UpdateAppartementState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? dataLoaded,
    String? errorMessage,
    Map<String, dynamic>? initialData,
  }) {
    return UpdateAppartementState(
      isLoading:
      isLoading ?? this.isLoading,
      isSaving:
      isSaving ?? this.isSaving,
      dataLoaded:
      dataLoaded ?? this.dataLoaded,
      errorMessage:
      errorMessage,
      initialData:
      initialData ?? this.initialData,
    );
  }
}