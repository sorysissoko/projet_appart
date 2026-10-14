// presentation/screens/dashboard/components/top_cities.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/dashboard_data.dart';

class TopCities extends StatelessWidget {
  final List<CityStats> cities;

  const TopCities({
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
            fontSize: 15.sp,
          ),
        ),
      );
    }

    final maxValue = cities.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Column(
      children: cities.map((city) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: city.colorValue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        city.name,
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${city.value}',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: FractionallySizedBox(
                  widthFactor: city.value / maxValue,
                  child: Container(
                    decoration: BoxDecoration(
                      color: city.colorValue,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}