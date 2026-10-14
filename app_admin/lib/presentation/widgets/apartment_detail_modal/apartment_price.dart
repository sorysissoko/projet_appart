import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ApartmentPrice extends StatelessWidget {
  final String formattedPrix;
  final double fraisService;
  final double prixProprietaire;
  final String Function(String) formatPrix;

  const ApartmentPrice({
    Key? key,
    required this.formattedPrix,
    required this.fraisService,
    required this.prixProprietaire,
    required this.formatPrix,
  }) : super(key: key);

  Widget _buildPriceRow({
    required String label,
    required String value,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: isBold ? 17.sp : 15.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? Colors.white : Colors.white60,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: isBold ? 17.sp : 15.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? (isBold ? Colors.white : Colors.white70),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détail financier',
          style: GoogleFonts.manrope(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF111622),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //PRIX PROPRIÉTAIRE
              _buildPriceRow(
                label: 'Part Propriétaire',
                value: formatPrix(prixProprietaire.toString()),
              ),
              SizedBox(height: 8.h),

              //FRAIS DE SERVICE
              _buildPriceRow(
                label: 'Frais de service',
                value: formatPrix(fraisService.toString()),
                valueColor: const Color(0xFFFFC107).withValues(alpha: 0.9),
              ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.08),
                  height: 1,
                ),
              ),

              //TOTAL
              _buildPriceRow(
                label: 'Prix total affiché',
                value: formattedPrix,
                isBold: true,
                valueColor: const Color(0xFFFFC107),
              ),
            ],
          ),
        ),
      ],
    );
  }
}