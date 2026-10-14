import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owner_app/core/theme/app_theme.dart';

import '../controller/ajouter_appartement_controller.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/rule_switch.dart';
import '../widgets/time_field.dart';

class StepRegles extends StatelessWidget {
  final AjouterAppartementController ctrl;

  const StepRegles({
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
          Text(
            'Règles du séjour',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.inputText,
            ),
          ),

          const SizedBox(height: 18),

          AppTextField(
            label: 'Description des règles',
            controller: form.descriptionRegleCtrl,
            placeholder:
            'Ex : Respecter le voisinage et garder le logement propre...',
            maxLines: 3,
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              Expanded(
                child: TimeField(
                  label: 'Heure d\'arrivée',
                  value: form.heureArrivee,
                  onTap: () => _pickTime(context, true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TimeField(
                  label: 'Heure de départ',
                  value: form.heureDepart,
                  onTap: () => _pickTime(context, false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          AppTextField(
            label: 'Nombre maximum de clients',
            controller: form.nombreClientCtrl,
            placeholder: 'Ex : 4',
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 8),

          // =====================================================
          // FUMEURS
          // =====================================================

          RuleSwitch(
            title: 'Fumeurs acceptés',
            value: form.fumeur,
            onChanged: ctrl.setFumeur,
          ),

          // =====================================================
          // ANIMAUX
          // =====================================================

          RuleSwitch(
            title: 'Animaux acceptés',
            value: form.animauxAcceptes,
            onChanged: ctrl.setAnimauxAcceptes,
          ),

          // =====================================================
          // CHIEN / CHAT
          // =====================================================

          if (form.animauxAcceptes) ...[
            const SizedBox(height: 4),

            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Column(
                children: [
                  RuleSwitch(
                    title: 'Animaux acceptés: Chien',
                    value: form.animauxChien,
                    onChanged: ctrl.setAnimauxChien,
                  ),

                  RuleSwitch(
                    title: 'Animaux acceptés: Chat',
                    value: form.animauxChat,
                    onChanged: ctrl.setAnimauxChat,
                  ),
                ],
              ),
            ),
          ],

          // =====================================================
          // FÊTES
          // =====================================================

          RuleSwitch(
            title: 'Fêtes autorisées',
            value: form.fetes,
            onChanged: ctrl.setFetes,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEURES
  // ============================================================

  Future<void> _pickTime(
      BuildContext context,
      bool arrival,
      ) async {
    final initial = arrival
        ? ctrl.form.heureArrivee
        : ctrl.form.heureDepart;

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked == null) return;

    if (arrival) {
      ctrl.setHeureArrivee(picked);
    } else {
      ctrl.setHeureDepart(picked);
    }
  }
}