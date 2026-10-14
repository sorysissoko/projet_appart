import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAppartementSection extends StatelessWidget {
  final String title;
  final Widget child;

  const AddAppartementSection({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  static const Color _amberColor = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: _amberColor,
            ),
          ),
        ),
        const SizedBox(height: 20),
        child,
        const Divider(height: 30, color: Colors.white10),
      ],
    );
  }
}