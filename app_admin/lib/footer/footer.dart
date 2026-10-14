import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF090D16),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Version simplifiée pour mobile
          if (MediaQuery.of(context).size.width < 600)
            Center(
              child: Text(
                '© 2026 ImmoGest Pro',
                style: GoogleFonts.manrope(
                  color: Colors.grey[500],
                  fontSize: 11.sp,
                ),
              ),
            )
          else
            Row(
              children: [
                Icon(
                  Icons.copyright,
                  color: Colors.grey[600],
                  size: 14.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  '2026 ImmoGest Pro · Tous droits réservés',
                  style: GoogleFonts.manrope(
                    color: Colors.grey[500],
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),

          // Version desktop avec infos supplémentaires
          if (MediaQuery.of(context).size.width >= 600) ...[
            Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  color: const Color(0xFFFFC107),
                  size: 12.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Version 1.0.0',
                  style: GoogleFonts.manrope(
                    color: Colors.grey[500],
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Icon(
                  Icons.security_outlined,
                  color: Colors.green[600],
                  size: 12.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Sécurisé',
                  style: GoogleFonts.manrope(
                    color: Colors.green[600],
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}