import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/dashboard_data.dart';

class PropertyDistribution extends StatelessWidget {
  final List<CityStats> cities;

  const PropertyDistribution({
    super.key,
    required this.cities,
  });

  @override
  Widget build(BuildContext context) {
    if (cities.isEmpty) {
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

    final total = cities.fold(0, (sum, city) => sum + city.value);

    return Column(
      children: [
        SizedBox(
          height: 120.h,
          child: Row(
            children: cities.map((city) {
              final percentage = (city.value / total) * 100;
              return Expanded(
                flex: city.value,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: city.colorValue,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(4.r),
                    ),
                  ),
                  height: (percentage / 100) * 120.h,
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 4.h,
          children: cities.map((city) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: city.colorValue,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  '${city.name} (${city.value})',
                  style: GoogleFonts.manrope(
                    color: Colors.grey[600],
                    fontSize: 11.sp,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        SizedBox(height: 4.h),
        Text(
          'Total: $total biens',
          style: GoogleFonts.manrope(
            color: Colors.grey[600],
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}