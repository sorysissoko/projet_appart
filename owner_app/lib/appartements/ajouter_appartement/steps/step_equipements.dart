import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owner_app/core/theme/app_theme.dart';

import '../controller/ajouter_appartement_controller.dart';
import '../widgets/app_card.dart';
import '../widgets/appartement_form_data.dart';

class StepEquipements extends StatelessWidget {
  final AjouterAppartementController ctrl;

  const StepEquipements({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final form = ctrl.form;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Équipements',
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inputText,
                  ),
                ),
              ),
              if (ctrl.nombreEquipementsSelectionnes > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${ctrl.nombreEquipementsSelectionnes} sélectionné(s)',
                    style: GoogleFonts.nunito(
                      color: AppColors.inputText,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppartementFormData.equipementsLabels.entries.map((e) {
              final bool selected = form.equipements[e.key] ?? false;
              return GestureDetector(
                onTap: () => ctrl.toggleEquipement(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color:
                    selected ? const Color(0xFFEEF2FA) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.cardForeground
                          : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    selected ? '✓ ${e.value}' : e.value,
                    style: GoogleFonts.nunito(
                      color: selected
                          ? AppColors.inputText
                          : AppColors.mutedForeground,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}