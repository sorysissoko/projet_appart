import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/navigation/main_wrapper.dart';

class GestionPhotosPage extends StatelessWidget {
  final NavigateCallback onNavigate;
  final String? appartementId;

  const GestionPhotosPage({
    super.key,
    required this.onNavigate,
    required this.appartementId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => onNavigate(AppPage.details, appartementId: appartementId),
        ),
        title: Text(
          'Gestion des photos',
          style: GoogleFonts.nunito(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Appartement : ${appartementId ?? "—"}\n\nPage à implémenter.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 15),
        ),
      ),
    );
  }
}