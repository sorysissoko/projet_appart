import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owner_app/core/theme/app_theme.dart';

import '../controller/ajouter_appartement_controller.dart';
import '../widgets/app_card.dart';

class StepDetails extends StatelessWidget {
  final AjouterAppartementController ctrl;

  const StepDetails({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final form = ctrl.form;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails du bien',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.inputText,
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Description',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.inputText,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: form.descriptionCtrl,
            maxLines: 6,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            decoration: _inputDecoration(
              'Décrivez votre bien, son ambiance, son quartier...',
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Date de disponibilité',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.inputText,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: ctrl.isSaving
                ? null
                : () => _selectDate(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 19,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    form.dateDisponibilite == null
                        ? 'Sélectionner une date'
                        : _formatDate(form.dateDisponibilite!),
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: form.dateDisponibilite == null
                          ? const Color(0xFF8A94A6)
                          : const Color(0xFF0F1B2D),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(color: const Color(0xFF8A94A6)),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.cardForeground,
          width: 1.5,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('fr', 'FR'),
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5, now.month, now.day),
      helpText: 'DATE DE DISPONIBILITÉ',
      cancelText: 'ANNULER',
      confirmText: 'VALIDER',
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.iconcolor,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.inputText,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;
    ctrl.setDateDisponibilite(picked);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}