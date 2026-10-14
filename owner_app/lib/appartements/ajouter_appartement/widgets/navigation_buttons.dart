import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Boutons Retour / Continuer en bas du formulaire.
class NavigationButtons extends StatelessWidget {
  final int step;
  final int totalSteps;
  final bool isSaving;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const NavigationButtons({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.isSaving,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLastStep = step == totalSteps;

    return Row(
      children: [
        if (step > 1) ...[
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: isSaving ? null : onPrevious,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                disabledBackgroundColor: Colors.white,
                side: const BorderSide(
                  color: Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Retour',
                style: GoogleFonts.nunito(
                  color: const Color(0xFF64748B),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isSaving ? null : onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: isLastStep
                  ? const Color(0xFF10B981)
                  : const Color(0xFF0C0CDF),
              disabledBackgroundColor: const Color(0xFF94A3B8),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isSaving
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              isLastStep ? '✓ Soumettre le bien' : 'Continuer →',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}