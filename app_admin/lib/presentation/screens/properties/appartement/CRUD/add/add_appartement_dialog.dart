import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service/date_service.dart';
import '../../../../../../../../../../../../../../services_appart/add_appartement_service.dart';
import '../../../../../../../../data/models/add_appartement/appartement_create.dart';
import '../../../../../../../../data/models/add_appartement/appartement_info_create.dart';
import '../../../../../../../../data/models/add_appartement/appartement_role_create.dart';
import '../../../../../widgets/add_appartement_modal/add_appartement_body.dart';

class AddAppartementDialog extends StatefulWidget {
  final String? defaultCity;
  final String? defaultType;
  final String? residenceId;

  const AddAppartementDialog({
    super.key,
    this.defaultCity,
    this.defaultType,
    this.residenceId,
  });

  @override
  State<AddAppartementDialog> createState() => _AddAppartementDialogState();
}

class _AddAppartementDialogState extends State<AddAppartementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _service = AddAppartementService();

  bool _isLoading = false;

  // Controllers
  final _titreCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _prixController = MoneyMaskedTextController(
    decimalSeparator: '',
    thousandSeparator: ' ',
    leftSymbol: 'XOF ',
    precision: 0,
  );
  final _nbreSejourCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  // Caracteristiques
  final _chambreCtrl = TextEditingController();
  final _salonCtrl = TextEditingController();
  final _doucheCtrl = TextEditingController();
  final _cuisineCtrl = TextEditingController();
  final _etageCtrl = TextEditingController();
  final _tailleCtrl = TextEditingController();
  bool _serviceInclus = false;
  bool _internet = false;
  bool _stationnement = false;
  bool _meuble = false;
  bool _climatisation = false;

  // Règles
  final _heureArriveeCtrl = TextEditingController();
  final _heureDepartCtrl = TextEditingController();
  final _nbreClientCtrl = TextEditingController();
  final _feteCtrl = TextEditingController();
  final _animauxCtrl = TextEditingController();
  final _fumeurCtrl = TextEditingController();
  final _descriptionRegleCtrl = TextEditingController();

  // Dates
  final _dateDebutController = TextEditingController();
  final _dateFinController = TextEditingController();

  // Photos
  List<XFile> _selectedImages = [];

  // Équipements
  Map<String, bool> _equipements = {
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
    'television': false,
    'alarme_monoxyde_carbone': false,
  };

  final Map<int, String> _feteText = {
    0: 'Pas de fêtes',
    1: 'Fêtes acceptées',
  };

  final Map<int, String> _animauxText = {
    0: 'Pas d animaux',
    1: 'Animaux acceptés: Chien',
    2: 'Animaux acceptés: Chat',
  };

  final Map<int, String> _fumeurText = {
    0: 'Fumeurs non acceptés',
    1: 'Fumeurs acceptés',
  };

  @override
  void initState() {
    super.initState();
    if (widget.defaultCity != null && widget.defaultCity!.isNotEmpty) {
      _villeCtrl.text = widget.defaultCity!;
    }
    if (widget.defaultType != null && widget.defaultType!.isNotEmpty) {
      _typeCtrl.text = widget.defaultType!;
    }
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _typeCtrl.dispose();
    _villeCtrl.dispose();
    _adresseCtrl.dispose();
    _prixController.dispose();
    _nbreSejourCtrl.dispose();
    _descriptionCtrl.dispose();
    _chambreCtrl.dispose();
    _salonCtrl.dispose();
    _doucheCtrl.dispose();
    _cuisineCtrl.dispose();
    _etageCtrl.dispose();
    _tailleCtrl.dispose();
    _heureArriveeCtrl.dispose();
    _heureDepartCtrl.dispose();
    _nbreClientCtrl.dispose();
    _feteCtrl.dispose();
    _animauxCtrl.dispose();
    _fumeurCtrl.dispose();
    _descriptionRegleCtrl.dispose();
    _dateDebutController.dispose();
    _dateFinController.dispose();
    super.dispose();
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex--;
      }

      final image = _selectedImages.removeAt(oldIndex);
      _selectedImages.insert(newIndex, image);
    });
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.manrope(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _addImages() async {
    try {
      final List<XFile>? images = await ImagePicker().pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (images != null && images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la sélection des photos: $e', Colors.red, Icons.error);
    }
  }

  void _clearAllImages() {
    setState(() {
      _selectedImages.clear();
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _updateEquipement(String key) {
    setState(() {
      _equipements[key] = !_equipements[key]!;
    });
  }

  Future<void> _submitForm() async {
    // 1. Validation du formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Vérification des heures
    if (_heureArriveeCtrl.text.isEmpty || _heureDepartCtrl.text.isEmpty) {
      _showSnackBar(
        'Veuillez sélectionner les heures d\'arrivée et de départ',
        Colors.orange,
        Icons.warning,
      );
      return;
    }

    // Vérification des dates
    if (_dateDebutController.text.isEmpty || _dateFinController.text.isEmpty) {
      _showSnackBar(
        'Veuillez sélectionner les dates de disponibilité',
        Colors.orange,
        Icons.warning,
      );
      return;
    }

    // Vérification du nombre de clients
    if (_nbreClientCtrl.text.isEmpty) {
      _showSnackBar(
        'Veuillez indiquer le nombre de clients maximum',
        Colors.orange,
        Icons.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      //Création de l'appartement
      final appartement = AppartementCreate(
        titre: _titreCtrl.text.trim(),
        adresse: _adresseCtrl.text.trim(),
        ville: _villeCtrl.text.trim(),
        type: _typeCtrl.text.trim(),
        prix: _prixController.numberValue.toDouble(),
        description: _descriptionCtrl.text.trim(),
        nbreSejour: _nbreSejourCtrl.text.trim(),
        equipements: _equipements,
        residenceId: widget.residenceId,
      );

      final appartementId = await _service.createAppartement(appartement);
      print('Appartement créé avec ID: $appartementId');

      // Parsing des heures
      final heureArriveParts = _heureArriveeCtrl.text.split(':');
      final heureDepartParts = _heureDepartCtrl.text.split(':');

      if (heureArriveParts.length != 2 || heureDepartParts.length != 2) {
        throw Exception('Format d\'heure invalide');
      }

      final heureArrive = TimeOfDay(
        hour: int.parse(heureArriveParts[0]),
        minute: int.parse(heureArriveParts[1]),
      );

      final heureDepart = TimeOfDay(
        hour: int.parse(heureDepartParts[0]),
        minute: int.parse(heureDepartParts[1]),
      );

      //Insertion des informations
      final info = AppartementInfoCreate(
        chambre: int.tryParse(_chambreCtrl.text) ?? 0,
        salon: int.tryParse(_salonCtrl.text) ?? 0,
        douche: int.tryParse(_doucheCtrl.text) ?? 0,
        cuisine: int.tryParse(_cuisineCtrl.text) ?? 0,
        etage: int.tryParse(_etageCtrl.text) ?? 0,
        taille: double.tryParse(_tailleCtrl.text) ?? 0.0,
        serviceInclus: _serviceInclus,
        internet: _internet,
        stationnement: _stationnement,
        meuble: _meuble,
        climatisation: _climatisation,
      );

      final appartementInfoId = await _service.insertAppartementInfo(
        appartementId,
        info,
      );
      print('Informations insérées avec ID: $appartementInfoId');

      final int feteInt = int.tryParse(_feteCtrl.text) ?? 0;
      final int animauxInt = int.tryParse(_animauxCtrl.text) ?? 0;
      final int fumeurInt = int.tryParse(_fumeurCtrl.text) ?? 0;

      final role = AppartementRoleCreate(
        description: _descriptionRegleCtrl.text.trim(),
        heureArrive: heureArrive,
        heureDepart: heureDepart,
        nombreClient: int.tryParse(_nbreClientCtrl.text) ?? 1,
        fete: _feteText[feteInt] ?? 'Pas de fêtes',
        animaux: _animauxText[animauxInt] ?? 'Pas d animaux',
        fumeur: _fumeurText[fumeurInt] ?? 'Fumeurs non acceptés',
      );

      await _service.insertAppartementRole(
        appartementId,
        role,
      );
      print('Règles insérées');

      // 9. Création des disponibilités
      final dateDebut = DateService.parseFromDisplay(_dateDebutController.text);
      final dateFin = DateService.parseFromDisplay(_dateFinController.text);

      if (dateDebut == null || dateFin == null) {
        _showSnackBar(
          'Format de date invalide. Utilisez dd/MM/yyyy',
          Colors.red,
          Icons.error,
        );
        return;
      }

      await _service.createDisponibilites(
        appartementId,
        dateDebut,
        dateFin,
      );
      print('Disponibilités créées');

      // 10. Upload des photos
      if (_selectedImages.isNotEmpty) {
        await _service.uploadPhotos(
          appartementId,
          _selectedImages,
              (current, total) {
            print('Upload: $current/$total');
          },
        );
        print('Photos uploadées');
      }

      if (!mounted) return;
      _showSnackBar('Appartement ajouté avec succès !', Colors.green, Icons.check_circle);
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      FocusScope.of(context).unfocus();
      Navigator.pop(context, true);

    } catch (e, stackTrace) {
      if (!mounted) return;
      print('❌ ERREUR DÉTAILLÉE: $e');
      print('📚 STACK TRACE: $stackTrace');

      _showSnackBar(
        'Erreur: ${e.toString().replaceFirst('Exception:', '')}',
        Colors.red,
        Icons.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF090D16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: AddAppartementBody(
        formKey: _formKey,
        titreCtrl: _titreCtrl,
        typeCtrl: _typeCtrl,
        villeCtrl: _villeCtrl,
        adresseCtrl: _adresseCtrl,
        prixController: _prixController,
        nbreSejourCtrl: _nbreSejourCtrl,
        descriptionCtrl: _descriptionCtrl,
        chambreCtrl: _chambreCtrl,
        salonCtrl: _salonCtrl,
        doucheCtrl: _doucheCtrl,
        cuisineCtrl: _cuisineCtrl,
        etageCtrl: _etageCtrl,
        tailleCtrl: _tailleCtrl,
        descriptionRegleCtrl: _descriptionRegleCtrl,
        heureArriveeCtrl: _heureArriveeCtrl,
        heureDepartCtrl: _heureDepartCtrl,
        nbreClientCtrl: _nbreClientCtrl,
        fumeurCtrl: _fumeurCtrl,
        animauxCtrl: _animauxCtrl,
        feteCtrl: _feteCtrl,
        dateDebutController: _dateDebutController,
        dateFinController: _dateFinController,
        selectedImages: _selectedImages,
        equipements: _equipements,
        serviceInclus: _serviceInclus,
        internet: _internet,
        stationnement: _stationnement,
        meuble: _meuble,
        climatisation: _climatisation,
        isLoading: _isLoading,
        onAddImages: _addImages,
        onClearAll: _clearAllImages,
        onRemoveImage: _removeImage,
        onServiceInclusChanged: (v) => setState(() => _serviceInclus = v),
        onInternetChanged: (v) => setState(() => _internet = v),
        onStationnementChanged: (v) => setState(() => _stationnement = v),
        onMeubleChanged: (v) => setState(() => _meuble = v),
        onClimatisationChanged: (v) => setState(() => _climatisation = v),
        onEquipementChanged: _updateEquipement,
        onCancel: () => Navigator.pop(context),
        onSubmit: _submitForm,
        onReorderImages: _reorderImages,
      ),
    );
  }
}