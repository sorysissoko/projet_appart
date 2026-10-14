import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service/date_service.dart';

class DarkPickerHelper {
  /// Ouvre le sélecteur de date natif avec un thème sombre et accentuation #FFC107
  static Future<void> selectDate({
    required BuildContext context,
    required TextEditingController controller,
    DateTime? initialDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFC107), // Ambre/Jaune
              onPrimary: Colors.black, // Texte sombre sur fond jaune pour meilleure lisibilité
              surface: Color(0xFF131B2E), // Card background
              onSurface: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF090D16)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = DateService.formatToDisplay(picked);
    }
  }

  /// Ouvre le sélecteur d'heure natif avec un thème sombre et accentuation #FFC107
  static Future<void> selectTime({
    required BuildContext context,
    required TextEditingController controller,
    TimeOfDay? initialTime,
  }) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFC107),
              onPrimary: Colors.black,
              surface: Color(0xFF131B2E),
              onSurface: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF090D16)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      controller.text = '$hour:$minute';
    }
  }
}

/// Champ personnalisé non-éditable cliquable avec bordure active #FFC107
class DarkPickerField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final VoidCallback onTap;
  final String? Function(String?)? validator;

  const DarkPickerField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.onTap,
    this.validator,
  });

  static const Color _kPrimaryAccent = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: GoogleFonts.manrope(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.manrope(color: _kPrimaryAccent, fontSize: 18.sp),
        filled: true,
        fillColor: const Color(0xFF131B2E),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20.r),
        suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.white38, size: 40.r),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Color(0xFFFFC107)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }
}