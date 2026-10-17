import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owner_app/core/theme/app_theme.dart';

import '../controller/ajouter_appartement_controller.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/residence_selector.dart';

/// Étape 1 du formulaire : sélection ou création d'une résidence.
class StepResidence extends StatelessWidget {
  final AjouterAppartementController ctrl;

  const StepResidence({
    super.key,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    final form = ctrl.form;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // HEADER
          // ============================================================

          _buildHeader(),

          const SizedBox(height: 24),

          // ============================================================
          // CHARGEMENT
          // ============================================================

          if (form.isLoadingResidences)
            _buildLoading()

          // ============================================================
          // AUCUNE RÉSIDENCE
          // ============================================================

          else if (
          form.residences.isEmpty &&
              !form.isCreatingNewResidence
          )
            _buildNoResidence()

          // ============================================================
          // SÉLECTION D'UNE RÉSIDENCE EXISTANTE
          // ============================================================

          else if (!form.isCreatingNewResidence)
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 320,
                  height: 50,
                  child: ResidenceSelector(
                    residences: form.residences,
                    selectedId: form.selectedResidenceId,
                    onChanged: ctrl.isSaving
                        ? null
                        : ctrl.selectExistingResidence,
                  ),
                ),
              ),

          const SizedBox(height: 16),

          // ============================================================
          // BOUTON CRÉER
          // ============================================================

          if (!form.isCreatingNewResidence)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: ctrl.isSaving
                    ? null
                    : ctrl.startCreatingNewResidence,
                icon: const Icon(
                  Icons.add_business_outlined,
                  size: 20,
                ),
                label: Text(
                  form.residences.isEmpty
                      ? 'Créer ma première résidence'
                      : 'Créer une nouvelle résidence',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.cardForeground,
                  side: const BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          // ============================================================
          // FORMULAIRE NOUVELLE RÉSIDENCE
          // ============================================================

          if (form.isCreatingNewResidence) ...[
            const SizedBox(height: 4),

            _buildNewResidenceForm(),

            const SizedBox(height: 14),

            // ----------------------------------------------------------
            // VILLE
            // ----------------------------------------------------------

            AppTextField(
              label: 'Ville de la résidence',
              controller: form.villeResidenceCtrl,
              placeholder: 'ex : Bamako',
            ),

            // ----------------------------------------------------------
            // ADRESSE
            // ----------------------------------------------------------

            AppTextField(
              label: 'Adresse de la résidence',
              controller: form.adresseResidenceCtrl,
              placeholder: 'ex : Hamdallaye ACI 2000',
            ),

            // ----------------------------------------------------------
            // LOCALISATION
            // ----------------------------------------------------------

            AppTextField(
              label: 'Localisation de la résidence',
              controller: form.localisationCtrl,
              placeholder: 'ex : 12.6392, -8.0029',
            ),
          ],
        ],
      ),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.business_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choisir une résidence',
                style: GoogleFonts.nunito(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.inputText,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Une résidence peut contenir plusieurs appartements.',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================================================================
  // LOADING
  // ================================================================

  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Chargement de vos résidences...',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // AUCUNE RÉSIDENCE
  // ================================================================

  Widget _buildNoResidence() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFD97706),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Vous n\'avez encore aucune résidence. '
                  'Créez votre première résidence pour pouvoir '
                  'y ajouter vos appartements.',
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: const Color(0xFF92400E),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // FORMULAIRE NOUVELLE RÉSIDENCE
  // ================================================================

  Widget _buildNewResidenceForm() {
    final form = ctrl.form;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.business_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nouvelle résidence',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inputText,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Annuler',
                onPressed: ctrl.isSaving
                    ? null
                    : ctrl.cancelCreatingNewResidence,
                icon: const Icon(
                  Icons.close,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'La résidence sera créée une seule fois, puis cet '
                'appartement y sera rattaché.',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: AppColors.mutedForeground,
            ),
          ),

          const SizedBox(height: 14),

          AppTextField(
            label: 'Nom de la résidence',
            controller: form.nomResidenceCtrl,
            placeholder: 'ex : Résidence FAKAM',
          ),

          AppTextField(
            label: 'Description de la résidence',
            controller: form.descriptionResidenceCtrl,
            placeholder:
            'ex : Résidence familiale de plusieurs appartements',
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}