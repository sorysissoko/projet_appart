import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service/date_service.dart';

import '../../../data/models/add_appartement/add_appartement_validators.dart';

class AddAppartementDates extends StatelessWidget {
  final TextEditingController dateDebutController;
  final TextEditingController dateFinController;

  const AddAppartementDates({
    Key? key,
    required this.dateDebutController,
    required this.dateFinController,
  }) : super(key: key);

  static const Color _amberColor = Color(0xFFFFC107);
  static const Color _inputTextColor = Color(0xFFB8B8B8);

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.manrope(
        color: Colors.white60,
        fontSize: 22.sp,
      ),
      floatingLabelStyle: GoogleFonts.manrope(
        color: _amberColor,
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.transparent,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.white30, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: _amberColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Widget _twoFields(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 15),
        Expanded(child: right),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _twoFields(
      TextFormField(
        controller: dateDebutController,
        style: GoogleFonts.manrope(
          color: _inputTextColor,
          fontSize: 20.sp,
          fontWeight: FontWeight.w500,
        ),
        readOnly: true,
        decoration: _inputDecoration("Date début"),
        validator: (value) => AddAppartementValidators.validateRequired(value, 'Date début'),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
            initialDate: DateTime.now(),
          );
          if (picked != null) {
            dateDebutController.text = DateService.formatToDisplay(picked);
          }
        },
      ),
      TextFormField(
        controller: dateFinController,
        style: GoogleFonts.manrope(
          color: _inputTextColor,
          fontSize: 20.sp,
          fontWeight: FontWeight.w500,
        ),
        readOnly: true,
        decoration: _inputDecoration("Date fin"),
        validator: (value) => AddAppartementValidators.validateRequired(value, 'Date fin'),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
            initialDate: DateTime.now(),
          );
          if (picked != null) {
            dateFinController.text = DateService.formatToDisplay(picked);
          }
        },
      ),
    );
  }
}