import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:image_picker/image_picker.dart';

class AddAppartementState {
  // Controllers
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

  // Data
  final List<XFile> selectedImages;
  final Map<String, bool> equipements;
  final bool serviceInclus;
  final bool internet;
  final bool stationnement;
  final bool meuble;
  final bool climatisation;
  final bool isLoading;

  AddAppartementState({
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
  });

  AddAppartementState copyWith({
    List<XFile>? selectedImages,
    Map<String, bool>? equipements,
    bool? serviceInclus,
    bool? internet,
    bool? stationnement,
    bool? meuble,
    bool? climatisation,
    bool? isLoading,
  }) {
    return AddAppartementState(
      titreCtrl: titreCtrl,
      typeCtrl: typeCtrl,
      villeCtrl: villeCtrl,
      adresseCtrl: adresseCtrl,
      prixController: prixController,
      nbreSejourCtrl: nbreSejourCtrl,
      descriptionCtrl: descriptionCtrl,
      chambreCtrl: chambreCtrl,
      salonCtrl: salonCtrl,
      doucheCtrl: doucheCtrl,
      cuisineCtrl: cuisineCtrl,
      etageCtrl: etageCtrl,
      tailleCtrl: tailleCtrl,
      descriptionRegleCtrl: descriptionRegleCtrl,
      heureArriveeCtrl: heureArriveeCtrl,
      heureDepartCtrl: heureDepartCtrl,
      nbreClientCtrl: nbreClientCtrl,
      fumeurCtrl: fumeurCtrl,
      animauxCtrl: animauxCtrl,
      feteCtrl: feteCtrl,
      dateDebutController: dateDebutController,
      dateFinController: dateFinController,
      selectedImages: selectedImages ?? this.selectedImages,
      equipements: equipements ?? this.equipements,
      serviceInclus: serviceInclus ?? this.serviceInclus,
      internet: internet ?? this.internet,
      stationnement: stationnement ?? this.stationnement,
      meuble: meuble ?? this.meuble,
      climatisation: climatisation ?? this.climatisation,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}