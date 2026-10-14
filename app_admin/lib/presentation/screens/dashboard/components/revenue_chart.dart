import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/dashboard_data.dart';

class RevenueChart extends StatelessWidget {
  final List<RevenueDataPoint> data;
  final String title;

  const RevenueChart({
    super.key,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Aucune donnée disponible',
          style: GoogleFonts.manrope(
            color: Colors.grey[600],
            fontSize: 14.sp,
          ),
        ),
      );
    }

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF111622),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '📊 Graphique ${data.length} mois',
          style: GoogleFonts.manrope(
            color: Colors.white60,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}