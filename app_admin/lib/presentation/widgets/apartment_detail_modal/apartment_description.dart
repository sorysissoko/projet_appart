// lib/presentation/screens/properties/appartement/Bamako/Appartement/CRUD/widgets/apartment_detail_modal/apartment_description.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ApartmentDescription extends StatelessWidget {
  final Map<String, dynamic> appartement;
  final String? roleDescription;

  const ApartmentDescription({
    Key? key,
    required this.appartement,
    this.roleDescription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasMainDescription = appartement['description']?.toString().trim().isNotEmpty == true;
    final hasRoleDescription = roleDescription?.trim().isNotEmpty == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
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
              // ─── DESCRIPTION PRINCIPALE ───
              Text(
                hasMainDescription
                    ? appartement['description'].toString()
                    : 'Aucune description disponible.',
                style: GoogleFonts.manrope(
                  fontSize: 17.sp,
                  height: 1.6,
                  color: hasMainDescription ? Colors.white70 : Colors.white38,
                ),
              ),

              // ─── DESCRIPTION DES RÈGLES / RÔLE (Si présente) ───
              if (hasRoleDescription) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.08),
                    height: 1,
                    thickness: 1,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.rule_folder_outlined,
                      color: Color(0xFFFFC107), // Accent doré
                      size: 25,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Règles & Consignes',
                      style: GoogleFonts.manrope(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFC107),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  roleDescription!,
                  style: GoogleFonts.manrope(
                    fontSize: 17.sp,
                    height: 1.6,
                    color: Colors.white70,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}