import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/update_appartement/update_appartement_viewmodel.dart';


class ActionButtons extends StatelessWidget {
  final UpdateAppartementViewModel viewModel;

  const ActionButtons({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    const primaryAccent = Color(0xFFFFC107);

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final state = viewModel.state;

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Bouton Annuler
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
              child: Text(
                'Annuler',
                style: GoogleFonts.manrope(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Bouton Enregistrer et Modifier
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAccent,
                foregroundColor: Colors.black,
                disabledBackgroundColor: primaryAccent.withValues(alpha: 0.5),
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              onPressed: state.isSaving ? null : () => _onUpdatePressed(context),
              child: state.isSaving
                  ? SizedBox(
                width: 18.r,
                height: 18.r,
                child: const CircularProgressIndicator(
                  color: Color(0xFFFFC107),
                  strokeWidth: 2,
                ),
              )
                  : Text(
                'Modifier',
                style: GoogleFonts.manrope(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onUpdatePressed(BuildContext context) async {
    if (!viewModel.formKey.currentState!.validate()) return;

    final success = await viewModel.updateAppartement();
    if (success && context.mounted) {
      Navigator.pop(context, true);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            viewModel.state.errorMessage ?? 'Erreur inconnue',
            style: GoogleFonts.manrope(color: Colors.white),
          ),
        ),
      );
    }
  }
}