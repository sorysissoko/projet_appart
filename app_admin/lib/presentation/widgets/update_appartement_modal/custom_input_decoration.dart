import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kPrimaryAccent = Color(0xFFFFC107);

InputDecoration darkInputDecoration(String label, {IconData? prefixIcon}) {
  return InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.manrope(color: _kPrimaryAccent, fontSize: 18.sp),
    filled: true,
    fillColor: const Color(0xFF131B2E),
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.white70, size: 20.r) : null,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: const BorderSide(color: Colors.white10),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: const BorderSide(color: Color(0xFFFFC107)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
  );
}