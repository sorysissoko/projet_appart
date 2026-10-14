import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/add_appartement/add_appartement_validators.dart';

class AddAppartementBasicInfo extends StatelessWidget {
  final TextEditingController titreCtrl;
  final TextEditingController typeCtrl;
  final TextEditingController villeCtrl;
  final TextEditingController adresseCtrl;
  final MoneyMaskedTextController prixController;
  final TextEditingController nbreSejourCtrl;
  final TextEditingController descriptionCtrl;

  const AddAppartementBasicInfo({
    Key? key,
    required this.titreCtrl,
    required this.typeCtrl,
    required this.villeCtrl,
    required this.adresseCtrl,
    required this.prixController,
    required this.nbreSejourCtrl,
    required this.descriptionCtrl,
  }) : super(key: key);

  static const Color _amberColor = Color(0xFFFFC107);
  static const Color _inputTextColor = Color(0xFFB8B8B8);

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.manrope(
        color: Colors.white60,
        fontSize: 20.sp,
      ),
      floatingLabelStyle: GoogleFonts.manrope(
        color: _amberColor,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.transparent,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.white30, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: _amberColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Widget _twoFields(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 15),
        Expanded(child: right),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _twoFields(
                  TextFormField(
                    controller: titreCtrl,
                    style: GoogleFonts.manrope(
                      color: _inputTextColor,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _inputDecoration("Nom de l'appartement"),
                    validator: (value) => AddAppartementValidators.validateMinLength(value, 5, 'Nom'),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration("Type"),
                    icon: const Icon(Icons.arrow_drop_down, color: _amberColor),
                    initialValue: typeCtrl.text.isEmpty ? null : typeCtrl.text,
                    isExpanded: true,
                    style: GoogleFonts.manrope(
                      color: _inputTextColor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return ['Appart', 'Villa'].map<Widget>((String value) {
                        return Text(
                          value == 'Appart' ? 'Appartement' : 'Villa',
                          style: GoogleFonts.manrope(
                            color: _inputTextColor,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList();
                    },
                    items: [
                      DropdownMenuItem(value: 'Appart', child: Text('Appartement', style: GoogleFonts.manrope(color: Colors.black87))),
                      DropdownMenuItem(value: 'Villa', child: Text('Villa', style: GoogleFonts.manrope(color: Colors.black87))),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        typeCtrl.text = newValue;
                      }
                    },
                    validator: (value) => AddAppartementValidators.validateRequired(value, 'Type'),
                  ),
                ),
                const SizedBox(height: 15),
                _twoFields(
                  TextFormField(
                    controller: villeCtrl,
                    style: GoogleFonts.manrope(
                      color: _inputTextColor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _inputDecoration("Ville"),
                    validator: (value) => AddAppartementValidators.validateRequired(value, 'Ville'),
                  ),
                  TextFormField(
                    controller: adresseCtrl,
                    style: GoogleFonts.manrope(
                      color: _inputTextColor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _inputDecoration("Adresse/Localisation"),
                    validator: (value) => AddAppartementValidators.validateMinLength(value, 5, 'Adresse'),
                  ),
                ),
                const SizedBox(height: 15),
                _twoFields(
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration("Nombre de séjour"),
                    icon: const Icon(Icons.arrow_drop_down, color: _amberColor),
                    initialValue: nbreSejourCtrl.text.isEmpty ? null : nbreSejourCtrl.text,
                    isExpanded: true,
                    style: GoogleFonts.manrope(
                      color: _inputTextColor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return ['nuit', 'mois'].map<Widget>((String value) {
                        return Text(
                          value,
                          style: GoogleFonts.manrope(
                            color: _inputTextColor,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList();
                    },
                    items: [
                      DropdownMenuItem(value: 'nuit', child: Text('nuit', style: GoogleFonts.manrope(color: Colors.black87))),
                      DropdownMenuItem(value: 'mois', child: Text('mois', style: GoogleFonts.manrope(color: Colors.black87))),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        nbreSejourCtrl.text = newValue;
                      }
                    },
                    validator: (value) => AddAppartementValidators.validateRequired(value, 'Nombre de séjour'),
                  ),
                  TextFormField(
                    controller: prixController,
                    style: GoogleFonts.manrope(
                      color: _inputTextColor,
                      fontSize: 23.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Prix (F CFA)'),
                    validator: (value) {
                      final prix = prixController.numberValue;
                      return AddAppartementValidators.validatePrix(prix);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: descriptionCtrl,
              style: GoogleFonts.manrope(
                color: _inputTextColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 7,
              decoration: _inputDecoration('Description'),
              validator: (value) => AddAppartementValidators.validateMinLength(value, 10, 'Description'),
            ),
          ),
        ],
      ),
    );
  }
}