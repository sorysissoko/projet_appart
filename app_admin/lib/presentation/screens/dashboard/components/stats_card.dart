import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final double? percentageChange;

  //Nouveaux paramètres pour la deuxième valeur
  final String? secondTitle;
  final String? secondValue;
  final IconData? secondIcon;
  final Color? secondColor;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.percentageChange,
    this.secondTitle,
    this.secondValue,
    this.secondIcon,
    this.secondColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111622),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //ICONE ET TITRE
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.manrope(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),

          //VALEUR PRINCIPALE
          Text(
            value,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 30.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          //DEUXIÈME VALEUR
          if (secondValue != null) ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                if (secondIcon != null)
                  Icon(
                    secondIcon,
                    color: secondColor ?? Colors.orange,
                    size: 14.sp,
                  ),
                if (secondIcon != null) SizedBox(width: 4.w),
                Text(
                  secondTitle ?? '',
                  style: GoogleFonts.manrope(
                    color: Colors.white54,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  secondValue!,
                  style: GoogleFonts.manrope(
                    color: secondColor ?? Colors.orange,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          //SUBTITLE
          if (subtitle != null) ...[
            SizedBox(height: 40.h),
            Text(
              subtitle!,
              style: GoogleFonts.manrope(
                color: Colors.white38,
                fontSize: 18.sp,
              ),
            ),
          ],

          //POURCENTAGE
          if (percentageChange != null) ...[
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  percentageChange! >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: percentageChange! >= 0 ? Colors.green : Colors.red,
                  size: 14.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${percentageChange!.abs()}%',
                  style: GoogleFonts.manrope(
                    color: percentageChange! >= 0 ? Colors.green : Colors.red,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
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