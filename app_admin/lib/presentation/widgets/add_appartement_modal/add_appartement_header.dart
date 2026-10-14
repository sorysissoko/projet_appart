import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAppartementHeader extends StatelessWidget {
  const AddAppartementHeader({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Text(
      "Ajouter un bien",
      style: GoogleFonts.manrope(
        fontSize: 25.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1,
      ),
    );
  }
}