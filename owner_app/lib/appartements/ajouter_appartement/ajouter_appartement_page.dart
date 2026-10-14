import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:admin/services_appart/add_appartement_service.dart';
import 'package:service/database_service.dart';

import '../../core/navigation/main_wrapper.dart';
import 'controller/ajouter_appartement_controller.dart';
import 'steps/step_caracteristiques.dart';
import 'steps/step_details.dart';
import 'steps/step_equipements.dart';
import 'steps/step_infos.dart';
import 'steps/step_regles.dart';
import 'steps/step_residence.dart';
import 'widgets/form_stepper.dart';
import 'widgets/navigation_buttons.dart';

class AjouterAppartementPage extends StatelessWidget {
  final NavigateCallback onNavigate;

  const AjouterAppartementPage({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final ctrl = AjouterAppartementController(
          service: AddAppartementService(),
          databaseService: DatabaseService(),
        );
        ctrl.onError = (msg) => _showSnack(context, msg, isError: true);
        ctrl.onInfo = (msg) => _showSnack(context, msg, isError: false);
        ctrl.onSuccess = () {
          Future.delayed(const Duration(milliseconds: 500), () {
            onNavigate(AppPage.mesAppartements);
          });
        };
        ctrl.initialize();
        return ctrl;
      },
      child: _PageBody(onNavigate: onNavigate),
    );
  }

  void _showSnack(BuildContext context, String message,
      {required bool isError}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.nunito()),
          backgroundColor:
          isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}

class _PageBody extends StatelessWidget {
  final NavigateCallback onNavigate;

  const _PageBody({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AjouterAppartementController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.transparent,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: FormStepper(currentStep: ctrl.step),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                children: [
                  _buildStep(ctrl),
                  const SizedBox(height: 20),
                  NavigationButtons(
                    step: ctrl.step,
                    totalSteps: AjouterAppartementController.totalSteps,
                    isSaving: ctrl.isSaving,
                    onNext: ctrl.nextStep,
                    onPrevious: ctrl.previousStep,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(AjouterAppartementController ctrl) {
    switch (ctrl.step) {
      case 1:
        return StepResidence(ctrl: ctrl);
      case 2:
        return StepInfos(ctrl: ctrl);
      case 3:
        return StepDetails(ctrl: ctrl);
      case 4:
        return StepCaracteristiques(ctrl: ctrl);
      case 5:
        return StepEquipements(ctrl: ctrl);
      case 6:
        return StepRegles(ctrl: ctrl);
      default:
        return const SizedBox.shrink();
    }
  }
}