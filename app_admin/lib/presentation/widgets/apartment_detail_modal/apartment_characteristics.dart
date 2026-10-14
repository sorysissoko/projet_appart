import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/detail_appartement/appartement_info.dart';
import '../../../data/models/detail_appartement/appartement_role.dart';

class ApartmentCharacteristics extends StatelessWidget {
  final AppartementInfo? info;
  final AppartementRole? role;

  const ApartmentCharacteristics({
    Key? key,
    required this.info,
    required this.role,
  }) : super(key: key);

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107).withValues(alpha: 0.1), // Accent jaune/doré léger
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 40.sp,
            color: const Color(0xFFFFC107),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 17.sp,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureTag(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 25.sp,
            color: const Color(0xFFFFC107),
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 15.sp,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Vérification s'il y a au moins un tag à afficher
    final hasTags = (info?.serviceInclus == true) ||
        (info?.internet == true) ||
        (info?.stationnement == true) ||
        (info?.meuble == true) ||
        (info?.climatisation == true) ||
        (role?.animaux == true) ||
        (role?.fete == true) ||
        (role?.fumeur == true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Caractéristiques',
          style: GoogleFonts.manrope(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF111622),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // ─── GRILLE DES STATISTIQUES (Chambres, Salon, etc.) ───
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.bed_outlined,
                        label: 'Chambres',
                        value: info?.chambre.toString() ?? '0',
                      ),
                      SizedBox(width: 24.w),
                      _buildStatItem(
                        icon: Icons.weekend_outlined,
                        label: 'Salon',
                        value: info?.salon.toString() ?? '0',
                      ),
                      SizedBox(width: 24.w),
                      _buildStatItem(
                        icon: Icons.shower_outlined,
                        label: 'Douches',
                        value: info?.douche.toString() ?? '0',
                      ),
                      SizedBox(width: 24.w),
                      _buildStatItem(
                        icon: Icons.kitchen_outlined,
                        label: 'Cuisine',
                        value: info?.cuisine.toString() ?? '0',
                      ),
                      SizedBox(width: 24.w),
                      _buildStatItem(
                        icon: Icons.stairs_outlined,
                        label: 'Étage',
                        value: info?.etage.toString() ?? '0',
                      ),
                      SizedBox(width: 24.w),
                      _buildStatItem(
                        icon: Icons.square_foot_outlined,
                        label: 'Surface',
                        value: '${info?.taille.toString() ?? '0'} m²',
                      ),
                    ],
                  ),
                ),

                // ─── SÉPARATEUR & TAGS (Si présents) ───
                if (hasTags) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.08),
                      height: 1,
                    ),
                  ),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    alignment: WrapAlignment.center,
                    children: [
                      if (info?.serviceInclus == true)
                        _buildFeatureTag('Service inclus', Icons.flash_on_outlined),
                      if (info?.internet == true)
                        _buildFeatureTag('Wi-Fi', Icons.wifi_outlined),
                      if (info?.stationnement == true)
                        _buildFeatureTag('Parking', Icons.local_parking_outlined),
                      if (info?.meuble == true)
                        _buildFeatureTag('Meublé', Icons.chair_outlined),
                      if (info?.climatisation == true)
                        _buildFeatureTag('Climatisation', Icons.ac_unit_outlined),
                      if (role?.animaux == true)
                        _buildFeatureTag('Animaux acceptés', Icons.pets_outlined),
                      if (role?.fete == true)
                        _buildFeatureTag('Fêtes acceptées', Icons.celebration_outlined),
                      if (role?.fumeur == true)
                        _buildFeatureTag('Fumeurs acceptés', Icons.smoking_rooms_outlined),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}