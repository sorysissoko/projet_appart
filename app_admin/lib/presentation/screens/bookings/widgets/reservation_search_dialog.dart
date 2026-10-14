import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ReservationSearchDialog {
  static void show(
      BuildContext context,
      List<Map<String, dynamic>> reservations,
      Function(String) onSearch,
      VoidCallback onReset,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111622),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text('Rechercher une réservation', style: GoogleFonts.manrope(color: Colors.white)),
        content: TextField(
          style:  GoogleFonts.manrope(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Titre, locataire...',
            hintStyle: GoogleFonts.manrope(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Colors.white38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFFFC107)),
            ),
          ),
          onChanged: (value) {
            if (value.isEmpty) {
              onReset();
            } else {
              onSearch(value);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer', style: GoogleFonts.manrope
              (color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              onReset();
              Navigator.pop(context);
            },
            child: Text('Réinitialiser', style: GoogleFonts.manrope
              (color: Color(0xFFFFC107))),
          ),
        ],
      ),
    );
  }
}