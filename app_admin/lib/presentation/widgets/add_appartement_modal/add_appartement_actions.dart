import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAppartementActions extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const AddAppartementActions({
    Key? key,
    required this.isLoading,
    required this.onCancel,
    required this.onSubmit,
  }) : super(key: key);

  static const Color _amberColor = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Annuler',
            style: GoogleFonts.manrope(
              color: Colors.white60,
              fontSize: 22.sp,
            ),
          ),
        ),
        const SizedBox(width: 15),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _amberColor,
            foregroundColor: const Color(0xFF090D16),
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 8.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
          onPressed: isLoading ? null : onSubmit,
          child: isLoading
              ? SizedBox(
            height: 20.h,
            width: 20.w,
            child: const CircularProgressIndicator(
              color: Color(0xFFFFC107),
              strokeWidth: 2,
            ),
          )
              : Text(
            'Ajouter',
            style: GoogleFonts.manrope(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF090D16),
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}