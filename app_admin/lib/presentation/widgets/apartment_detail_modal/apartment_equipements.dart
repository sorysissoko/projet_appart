import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ApartmentEquipements extends StatelessWidget {
  final Map<String, bool> equipements;

  const ApartmentEquipements({
    Key? key,
    required this.equipements,
  }) : super(key: key);

  static const Map<String, IconData> _equipementIcons = {
    'baignoire': Icons.bathtub_outlined,
    'seche_cheveux': Icons.face_retouching_natural_outlined,
    'produits_nettoyage': Icons.cleaning_services_outlined,
    'shampooing': Icons.spa_outlined,
    'savon_corps': Icons.soap_outlined,
    'eau_chaude': Icons.water_drop_outlined,
    'gel_douche': Icons.shower_outlined,
    'laveuse_gratuite': Icons.local_laundry_service_outlined,
    'secheuse_gratuite': Icons.dry_cleaning_outlined,
    'serviettes_draps': Icons.bed_outlined,
    'cintres': Icons.checkroom_outlined,
    'fer_repasser': Icons.iron_outlined,
    'sechoir_vetements': Icons.wash_outlined,
    'cuisine': Icons.kitchen_outlined,
    'refrigerateur': Icons.kitchen_outlined,
    'micro_ondes': Icons.microwave_outlined,
    'bases_cuisine': Icons.restaurant_outlined,
    'plats_argenterie': Icons.dinner_dining_outlined,
    'congelateur': Icons.ac_unit_outlined,
    'lave_vaisselle': Icons.cleaning_services_outlined,
    'cuisiniere_gaz': Icons.fireplace_outlined,
    'four': Icons.electric_bolt_outlined,
    'bouilloire': Icons.coffee_maker_outlined,
    'cafetiere': Icons.coffee_maker_outlined,
    'verres_vin': Icons.wine_bar_outlined,
    'grille_pain': Icons.restaurant_outlined,
    'mixeur': Icons.blender_outlined,
    'table_manger': Icons.dining_outlined,
    'serrure_chambre': Icons.lock_outlined,
    'camera_exterieure': Icons.videocam_outlined,
    'television': Icons.tv_outlined,
    'alarme_monoxyde_carbone': Icons.shield_outlined,
  };

  /// Fonction pour formater proprement les clés (ex: "eau_chaude" -> "Eau chaude")
  String _formatLabel(String key) {
    if (key.isEmpty) return '';
    final formatted = key.replaceAll('_', ' ');
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final activeEquipements = equipements.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    if (activeEquipements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Équipements (${activeEquipements.length})',
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
          child: Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: activeEquipements.map((key) {
              final icon = _equipementIcons[key] ?? Icons.check_circle_outline;
              final label = _formatLabel(key);

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
                      label,
                      style: GoogleFonts.manrope(
                        fontSize: 15.sp,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}