// lib/presentation/screens/properties/appartement/Bamako/Appartement/CRUD/widgets/apartment_detail_modal/apartment_footer.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ApartmentFooter extends StatelessWidget {
  final String formattedPrix;
  final String? nbreSejour;
  final VoidCallback onClose;
  final VoidCallback onContact;
  final String? status;
  final VoidCallback? onPublish;
  final VoidCallback? onRefuse;

  const ApartmentFooter({
    Key? key,
    required this.formattedPrix,
    this.nbreSejour,
    required this.onClose,
    required this.onContact,
    this.status,
    this.onPublish,
    this.onRefuse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String displaySejour = nbreSejour ?? '';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF111622), // Fond anthracite du Dashboard
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16.r),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08), // Séparateur discret
            width: 1.w,
          ),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16.w,
        runSpacing: 12.h,
        children: [
          // ─── AFFICHAGE DU PRIX ───
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.payments_outlined,
                  size: 25.sp,
                  color: const Color(0xFFFFC107), // Icône dorée
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                formattedPrix,
                style: GoogleFonts.manrope(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (displaySejour.isNotEmpty) ...[
                SizedBox(width: 4.w),
                Text(
                  '/ $displaySejour',
                  style: GoogleFonts.manrope(
                    fontSize: 15.sp,
                    color: Colors.white54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),

          // ─── BOUTONS D'ACTION ───
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              SizedBox(width: 100.w),

              // Actions contextuelles d'administration (Publier / Refuser)
              if (status == 'en_attente') ...[
                ElevatedButton.icon(
                  onPressed: onPublish,
                  icon: Icon(Icons.check_circle_outline, size: 20.sp, color: Colors.white),
                  label: Text(
                    'Publier',
                    style: GoogleFonts.manrope(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    backgroundColor: const Color(0xFF2E7D32),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),

                SizedBox(width: 30.w),

                ElevatedButton.icon(
                  onPressed: onRefuse,
                  icon: Icon(Icons.cancel_outlined, size: 20.sp, color: Colors.white),
                  label: Text(
                    'Refuser',
                    style: GoogleFonts.manrope(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    backgroundColor: const Color(0xFFC62828),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                SizedBox(width: 50.w),
              ],

              // Bouton Principal : Contacter
              ElevatedButton.icon(
                onPressed: onContact,
                icon: Icon(Icons.chat_bubble_outline, size: 20.sp, color: Colors.black87),
                label: Text(
                  "Contacter",
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  backgroundColor: const Color(0xFFFFC107),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),

              SizedBox(width: 50.w),

              // Bouton Fermer
              TextButton(
                onPressed: onClose,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  foregroundColor: Colors.white60,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  "Fermer",
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}