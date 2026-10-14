// lib/presentation/screens/properties/appartement/update/widgets/shared_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// Couleurs du thème sombre
const Color _kCardColor = Color(0xFF131B2E);
const Color _kPrimaryAccent = Color(0xFFFFC107);


/// Disposition en deux colonnes avec espacement responsive
Widget twoFields(Widget a, Widget b) {
  return Padding(
    padding: EdgeInsets.only(bottom: 15.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        SizedBox(width: 12.w),
        Expanded(child: b),
      ],
    ),
  );
}

//Décoration commune pour les champs de texte en mode sombre
InputDecoration inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.manrope(color: Colors.white60),
    floatingLabelStyle: GoogleFonts.manrope(color: _kPrimaryAccent),
    filled: true,
    fillColor: _kCardColor,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: Colors.white10, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: _kPrimaryAccent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: Colors.redAccent.shade100, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
    errorStyle: GoogleFonts.manrope(
      fontSize: 11.sp,
      color: Colors.redAccent.shade100,
    ),
  );
}

/// Champ numérique compact stylisé pour le thème sombre
Widget miniNumberField(
    TextEditingController ctrl,
    String label,
    String? Function(String?) validator, {
      double? width,
    }) {
  return SizedBox(
    width: width ?? 100.w,
    child: TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: GoogleFonts.manrope(
        color: Colors.white,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.manrope(color: Colors.white60, fontSize: 18.sp),
        floatingLabelStyle: GoogleFonts.manrope(color: _kPrimaryAccent, fontSize: 18.sp),
        filled: true,
        fillColor: _kCardColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.white10, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _kPrimaryAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.redAccent.shade100, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: GoogleFonts.manrope(height: 0, fontSize: 0),
      ),
      validator: validator,
    ),
  );
}

Widget buildCheckbox(String label, bool value, Function(bool) onChanged) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(20.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: value ? _kPrimaryAccent.withValues(alpha: 0.15) : _kCardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: value ? _kPrimaryAccent : Colors.white10,
            width: value ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 16.r,
              color: value ? _kPrimaryAccent : Colors.white38,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.manrope(
                color: value ? Colors.white : Colors.white70,
                fontSize: 12.5.sp,
                fontWeight: value ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}