import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Stepper horizontal affiché en haut de la page.
///
/// Affiche 6 étapes avec :
/// - un rond numéroté (ou ✓ si terminé)
/// - un trait de liaison coloré si l'étape est passée
/// - un label sous le rond
class FormStepper extends StatelessWidget {
  final int currentStep;

  /// Labels dans l'ordre des étapes (1 → 6).
  static const List<String> _labels = [
    'Résidence',
    'Infos',
    'Détails',
    'Carac.',
    'Équi.',
    'Règles',
  ];

  const FormStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < _labels.length; i++) ...[
            Expanded(
              child: _MiniStep(
                title: _labels[i],
                stepNum: i + 1,
                currentStep: currentStep,
              ),
            ),
            if (i < _labels.length - 1)
              _StepLine(
                stepBefore: i + 1,
                currentStep: currentStep,
              ),
          ],
        ],
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final int stepBefore;
  final int currentStep;

  const _StepLine({
    required this.stepBefore,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final bool done = currentStep > stepBefore;

    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(left: 6, right: 6, bottom: 18),
        decoration: BoxDecoration(
          color: done ? const Color(0xFF0C0CDF) : Colors.white24,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _MiniStep extends StatelessWidget {
  final String title;
  final int stepNum;
  final int currentStep;

  const _MiniStep({
    required this.title,
    required this.stepNum,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = currentStep == stepNum;
    final bool done = currentStep > stepNum;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? const Color(0xFF0C0CDF)
                : active
                ? Colors.grey
                : const Color(0xFF2C3E5D),
            border: Border.all(
              color: done
                  ? const Color(0xFF0C0CDF)
                  : active
                  ? Colors.white
                  : Colors.white24,
            ),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, size: 17, color: Colors.white)
                : Text(
              '$stepNum',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: active
                    ? const Color(0xFF0F1B2D)
                    : Colors.white70,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active
                ? Colors.grey
                : done
                ? const Color(0xFF0C0CDF)
                : Colors.white60,
          ),
        ),
      ],
    );
  }
}