import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/detail_appartement/appartement_info.dart';
import '../../../data/models/detail_appartement/appartement_role.dart';
import 'apartment_gallery.dart';
import 'apartment_characteristics.dart';
import 'apartment_equipements.dart';
import 'apartment_description.dart';
import 'apartment_information.dart';
import 'apartment_price.dart';

class ApartmentDetailBody extends StatelessWidget {
  final Map<String, dynamic> appartement;
  final List<String> images;
  final AppartementInfo? info;
  final AppartementRole? role;
  final Map<String, bool> equipements;
  final String Function(String) formatPrix;
  final VoidCallback onImageTap;

  const ApartmentDetailBody({
    Key? key,
    required this.appartement,
    required this.images,
    required this.info,
    required this.role,
    required this.equipements,
    required this.formatPrix,
    required this.onImageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prix = double.tryParse(appartement['prix']?.toString() ?? '0') ?? 0.0;
    final formattedPrix = formatPrix(prix.toString());
    final fraisService = double.tryParse((appartement['frais_service'] ?? 0).toString()) ?? 0.0;
    final prixProprietaire = double.tryParse((appartement['prix_proprietaire'] ?? 0).toString()) ?? 0.0;

    final hasEquipements = equipements.values.any((v) => v == true);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── LIGNE : GALERIE PHOTOS + (CARACTÉRISTIQUES + ÉQUIPEMENTS) ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 30,
                child: images.isNotEmpty
                    ? ApartmentGallery(
                  images: images,
                  onImageTap: onImageTap,
                )
                    : Container(
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F2E),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 48.sp,
                          color: Colors.white24,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Aucune photo',
                          style: GoogleFonts.manrope(
                            color: Colors.white38,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                flex: 45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ApartmentCharacteristics(
                      info: info,
                      role: role,
                    ),
                    if (hasEquipements) ...[
                      SizedBox(height: 24.h),
                      ApartmentEquipements(
                        equipements: equipements,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 30.h),

          // ─── LIGNE : DESCRIPTION + (INFORMATIONS SUPPLÉMENTAIRES + DÉTAIL FINANCIER) ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colonne gauche : Description
              Expanded(
                flex: 1,
                child: ApartmentDescription(
                  appartement: appartement,
                  roleDescription: role?.description,
                ),
              ),
              SizedBox(width: 20.w),
              // Colonne droite : Informations + Détail financier
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ApartmentInformation(
                      role: role,
                      nombreClient: appartement['nombre_client'] as int?,
                    ),
                    SizedBox(height: 24.h),
                    ApartmentPrice(
                      formattedPrix: formattedPrix,
                      fraisService: fraisService,
                      prixProprietaire: prixProprietaire,
                      formatPrix: formatPrix,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}