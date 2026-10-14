import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'add_appartement_header.dart';
import 'add_appartement_section.dart';
import 'add_appartement_basic_info.dart';
import 'add_appartement_photos.dart';
import 'add_appartement_characteristics.dart';
import 'add_appartement_rules.dart';
import 'add_appartement_dates.dart';
import 'add_appartement_equipements.dart';
import 'add_appartement_actions.dart';

class AddAppartementBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titreCtrl;
  final TextEditingController typeCtrl;
  final TextEditingController villeCtrl;
  final TextEditingController adresseCtrl;
  final MoneyMaskedTextController prixController;
  final TextEditingController nbreSejourCtrl;
  final TextEditingController descriptionCtrl;
  final TextEditingController chambreCtrl;
  final TextEditingController salonCtrl;
  final TextEditingController doucheCtrl;
  final TextEditingController cuisineCtrl;
  final TextEditingController etageCtrl;
  final TextEditingController tailleCtrl;
  final TextEditingController descriptionRegleCtrl;
  final TextEditingController heureArriveeCtrl;
  final TextEditingController heureDepartCtrl;
  final TextEditingController nbreClientCtrl;
  final TextEditingController fumeurCtrl;
  final TextEditingController animauxCtrl;
  final TextEditingController feteCtrl;
  final TextEditingController dateDebutController;
  final TextEditingController dateFinController;
  final List<XFile> selectedImages;
  final Map<String, bool> equipements;
  final bool serviceInclus;
  final bool internet;
  final bool stationnement;
  final bool meuble;
  final bool climatisation;
  final bool isLoading;

  final VoidCallback onAddImages;
  final VoidCallback onClearAll;
  final Function(int) onRemoveImage;
  final ValueChanged<bool> onServiceInclusChanged;
  final ValueChanged<bool> onInternetChanged;
  final ValueChanged<bool> onStationnementChanged;
  final ValueChanged<bool> onMeubleChanged;
  final ValueChanged<bool> onClimatisationChanged;
  final ValueChanged<String> onEquipementChanged;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  final void Function(int oldIndex, int newIndex) onReorderImages;

  const AddAppartementBody({
    Key? key,
    required this.formKey,
    required this.titreCtrl,
    required this.typeCtrl,
    required this.villeCtrl,
    required this.adresseCtrl,
    required this.prixController,
    required this.nbreSejourCtrl,
    required this.descriptionCtrl,
    required this.chambreCtrl,
    required this.salonCtrl,
    required this.doucheCtrl,
    required this.cuisineCtrl,
    required this.etageCtrl,
    required this.tailleCtrl,
    required this.descriptionRegleCtrl,
    required this.heureArriveeCtrl,
    required this.heureDepartCtrl,
    required this.nbreClientCtrl,
    required this.fumeurCtrl,
    required this.animauxCtrl,
    required this.feteCtrl,
    required this.dateDebutController,
    required this.dateFinController,
    required this.selectedImages,
    required this.equipements,
    required this.serviceInclus,
    required this.internet,
    required this.stationnement,
    required this.meuble,
    required this.climatisation,
    required this.isLoading,
    required this.onAddImages,
    required this.onClearAll,
    required this.onRemoveImage,
    required this.onServiceInclusChanged,
    required this.onInternetChanged,
    required this.onStationnementChanged,
    required this.onMeubleChanged,
    required this.onClimatisationChanged,
    required this.onEquipementChanged,
    required this.onCancel,
    required this.onSubmit,
    required this.onReorderImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1100.w,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AddAppartementHeader(),
              const SizedBox(height: 40),
              AddAppartementBasicInfo(
                titreCtrl: titreCtrl,
                typeCtrl: typeCtrl,
                villeCtrl: villeCtrl,
                adresseCtrl: adresseCtrl,
                prixController: prixController,
                nbreSejourCtrl: nbreSejourCtrl,
                descriptionCtrl: descriptionCtrl,
              ),
              const Divider(height: 30, color: Colors.white10),
              AddAppartementPhotos(
                selectedImages: selectedImages,
                onAddImages: onAddImages,
                onClearAll: onClearAll,
                onRemoveImage: onRemoveImage,
                onReorder: onReorderImages,
              ),
              const Divider(height: 30, color: Colors.white10),
              AddAppartementSection(
                title: 'Caractéristiques',
                child: AddAppartementCharacteristics(
                  chambreCtrl: chambreCtrl,
                  salonCtrl: salonCtrl,
                  doucheCtrl: doucheCtrl,
                  cuisineCtrl: cuisineCtrl,
                  etageCtrl: etageCtrl,
                  tailleCtrl: tailleCtrl,
                  serviceInclus: serviceInclus,
                  internet: internet,
                  stationnement: stationnement,
                  meuble: meuble,
                  climatisation: climatisation,
                  onServiceInclusChanged: onServiceInclusChanged,
                  onInternetChanged: onInternetChanged,
                  onStationnementChanged: onStationnementChanged,
                  onMeubleChanged: onMeubleChanged,
                  onClimatisationChanged: onClimatisationChanged,
                ),
              ),
              AddAppartementSection(
                title: 'Règles',
                child: AddAppartementRules(
                  descriptionRegleCtrl: descriptionRegleCtrl,
                  heureArriveeCtrl: heureArriveeCtrl,
                  heureDepartCtrl: heureDepartCtrl,
                  nbreClientCtrl: nbreClientCtrl,
                  fumeurCtrl: fumeurCtrl,
                  animauxCtrl: animauxCtrl,
                  feteCtrl: feteCtrl,
                ),
              ),
              AddAppartementSection(
                title: 'Dates de disponibilité',
                child: Column(
                  children: [
                    const SizedBox(height: 2),
                    AddAppartementDates(
                      dateDebutController: dateDebutController,
                      dateFinController: dateFinController,
                    ),
                  ],
                ),
              ),
              AddAppartementSection(
                title: 'Équipements',
                child: AddAppartementEquipements(
                  equipements: equipements,
                  onEquipementChanged: onEquipementChanged,
                ),
              ),
              const SizedBox(height: 10),
              AddAppartementActions(
                isLoading: isLoading,
                onCancel: onCancel,
                onSubmit: onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}