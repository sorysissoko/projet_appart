import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owner_app/core/theme/app_theme.dart';

import '../controller/ajouter_appartement_controller.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/price_field.dart';

class StepInfos extends StatelessWidget {
  final AjouterAppartementController ctrl;

  const StepInfos({super.key, required this.ctrl});

  static const _typesBiens = ['studio', 'appart', 'villa'];
  static const _dureesSejour = ['nuit', 'mois'];

  @override
  Widget build(BuildContext context) {
    final form = ctrl.form;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations générales',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.inputText,
            ),
          ),
          const SizedBox(height: 18),

          // Nom
          AppTextField(
            label: 'Nom de l\'appartement',
            controller: form.nomAppartementCtrl,
            placeholder: 'ex : Studio cosy centre-ville',
          ),

          // Type
          _sectionTitle('Type de bien'),
          const SizedBox(height: 8),
          _buildChips(
            values: _typesBiens,
            selected: form.type,
            onSelect: ctrl.setType,
          ),
          const SizedBox(height: 18),

          PriceField(controller: form.prixCtrl),

          _sectionTitle('Durée du séjour'),
          const SizedBox(height: 8),
          _buildChips(
            values: _dureesSejour,
            selected: form.dureeSejour,
            onSelect: ctrl.setDureeSejour,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.inputText,
      ),
    );
  }

  Widget _buildChips({
    required List<String> values,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((v) {
        final bool isSelected = v == selected;
        return GestureDetector(
          onTap: ctrl.isSaving ? null : () => onSelect(v),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEEF2FA) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.cardForeground
                    : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: Text(
              v[0].toUpperCase() + v.substring(1),
              style: GoogleFonts.nunito(
                color: isSelected
                    ? AppColors.inputText
                    : AppColors.mutedForeground,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}