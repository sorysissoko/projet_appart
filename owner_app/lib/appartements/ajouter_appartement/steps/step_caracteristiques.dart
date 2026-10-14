import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owner_app/core/theme/app_theme.dart';

import '../controller/ajouter_appartement_controller.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/option_switch.dart';
import '../widgets/photo_picker_section.dart';

class StepCaracteristiques extends StatelessWidget {
  final AjouterAppartementController ctrl;

  const StepCaracteristiques({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final form = ctrl.form;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Caractéristiques'),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Chambres',
                  controller: form.chambreCtrl,
                  placeholder: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppTextField(
                  label: 'Salons',
                  controller: form.salonCtrl,
                  placeholder: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Salles de bain',
                  controller: form.doucheCtrl,
                  placeholder: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppTextField(
                  label: 'Cuisines',
                  controller: form.cuisineCtrl,
                  placeholder: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Étage',
                  controller: form.etageCtrl,
                  placeholder: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppTextField(
                  label: 'Taille (m²)',
                  controller: form.tailleCtrl,
                  placeholder: '0',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          _title('Services et équipements'),
          const SizedBox(height: 12),

          OptionSwitch(
            title: 'Service inclus',
            value: form.serviceInclus,
            onChanged: ctrl.setServiceInclus,
          ),
          OptionSwitch(
            title: 'Internet',
            value: form.internet,
            onChanged: ctrl.setInternet,
          ),
          OptionSwitch(
            title: 'Stationnement',
            value: form.stationnement,
            onChanged: ctrl.setStationnement,
          ),
          OptionSwitch(
            title: 'Meublé',
            value: form.meuble,
            onChanged: ctrl.setMeuble,
          ),
          OptionSwitch(
            title: 'Climatisation',
            value: form.climatisation,
            onChanged: ctrl.setClimatisation,
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          PhotoPickerSection(
            images: form.selectedImages.cast(),
            isSaving: ctrl.isSaving,
            onPick: ctrl.pickImages,
            onRemove: ctrl.removeImage,
            onClear: ctrl.clearImages,
          ),
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.inputText,
      ),
    );
  }
}