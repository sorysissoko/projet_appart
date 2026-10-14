import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/add_appartement/add_appartement_validators.dart';

class AddAppartementCharacteristics extends StatelessWidget {
  final TextEditingController chambreCtrl;
  final TextEditingController salonCtrl;
  final TextEditingController doucheCtrl;
  final TextEditingController cuisineCtrl;
  final TextEditingController etageCtrl;
  final TextEditingController tailleCtrl;
  final bool serviceInclus;
  final bool internet;
  final bool stationnement;
  final bool meuble;
  final bool climatisation;
  final ValueChanged<bool> onServiceInclusChanged;
  final ValueChanged<bool> onInternetChanged;
  final ValueChanged<bool> onStationnementChanged;
  final ValueChanged<bool> onMeubleChanged;
  final ValueChanged<bool> onClimatisationChanged;

  const AddAppartementCharacteristics({
    Key? key,
    required this.chambreCtrl,
    required this.salonCtrl,
    required this.doucheCtrl,
    required this.cuisineCtrl,
    required this.etageCtrl,
    required this.tailleCtrl,
    required this.serviceInclus,
    required this.internet,
    required this.stationnement,
    required this.meuble,
    required this.climatisation,
    required this.onServiceInclusChanged,
    required this.onInternetChanged,
    required this.onStationnementChanged,
    required this.onMeubleChanged,
    required this.onClimatisationChanged,
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
        fontSize: 17.sp,
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

  Widget _miniNumberField(TextEditingController controller, String hint) {
    return Container(
      width: 120.w,
      margin: EdgeInsets.only(left:10.w, right: 10.w),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: GoogleFonts.manrope(
          color: _inputTextColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
        decoration: _inputDecoration(hint),
        validator: AddAppartementValidators.validateNumber,
      ),
    );
  }

  Widget _check(String label, bool value, ValueChanged<bool> onChanged) {
    return SizedBox(
      width: 210.w,
      child: CheckboxListTile(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
        ),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _amberColor;
          }
          return Colors.white24;
        }),
        checkColor: const Color(0xFF090D16),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ligne des champs numériques (scrollable horizontalement)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _miniNumberField(chambreCtrl, 'Chambre'),
                _miniNumberField(salonCtrl, 'Salon'),
                _miniNumberField(doucheCtrl, 'Douche'),
                _miniNumberField(cuisineCtrl, 'Cuisine'),
                _miniNumberField(etageCtrl, 'Étage'),
                _miniNumberField(tailleCtrl, 'Taille (m²)'),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // Wrap des checkboxes
          Padding(
            padding: EdgeInsets.only(bottom: 15.h),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 1,
              runSpacing: 1,
              children: [
                _check('Service inclus', serviceInclus, onServiceInclusChanged),
                _check('Internet', internet, onInternetChanged),
                _check('Stationnement', stationnement, onStationnementChanged),
                _check('Meuble', meuble, onMeubleChanged),
                _check('Climatisation', climatisation, onClimatisationChanged),
              ],
            ),
          ),
        ],
      ),
    );
  }
}