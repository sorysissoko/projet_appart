import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class UserDetailsDialog {
  static void showLocataireDetails(
      BuildContext context,
      Map<String, dynamic> locataire,
      ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400.w,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: const Color(0xFF111622),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '👤 Informations du locataire',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white60),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(color: Colors.white.withValues(alpha: 0.1)),
              SizedBox(height: 16.h),
              Row(
                children: [
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: const Color(0xFFFFC107),
                    child: Text(
                      '${locataire['prenom']?[0] ?? ''}${locataire['nom']?[0] ?? ''}',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFF090D16),
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${locataire['prenom'] ?? ''} ${locataire['nom'] ?? ''}',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        _buildInfoRow(Icons.email, locataire['email'] ?? 'Email non disponible'),
                        SizedBox(height: 4.h),
                        _buildInfoRow(Icons.phone, locataire['telephone'] ?? 'Téléphone non disponible'),
                        if (locataire['adresse'] != null) ...[
                          SizedBox(height: 4.h),
                          _buildInfoRow(Icons.home, locataire['adresse'] ?? 'Adresse non disponible'),
                        ],
                        if (locataire['urgencephone'] != null) ...[
                          SizedBox(height: 4.h),
                          _buildInfoRow(Icons.phone_android, locataire['urgencephone'] ?? 'N° Urgence non disponible'),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0F1E),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID du locataire',
                      style: GoogleFonts.manrope(
                        color: Colors.white38,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      locataire['id'] ?? 'Non disponible',
                      style: GoogleFonts.manrope(
                        color: Colors.white54,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: const Color(0xFF090D16),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showProprietaireDetails(
      BuildContext context,
      Map<String, dynamic> proprietaire,
      ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400.w,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: const Color(0xFF111622),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🏢 Informations du propriétaire',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white60),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(color: Colors.white.withValues(alpha: 0.1)),
              SizedBox(height: 16.h),
              Row(
                children: [
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: const Color(0xFF10B981),
                    child: Text(
                      '${proprietaire['prenom']?[0] ?? ''}${proprietaire['nom']?[0] ?? ''}',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFF090D16),
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${proprietaire['prenom'] ?? ''} ${proprietaire['nom'] ?? ''}',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        _buildInfoRow(Icons.email, proprietaire['email'] ?? 'Email non disponible'),
                        SizedBox(height: 4.h),
                        _buildInfoRow(Icons.phone, proprietaire['telephone'] ?? 'Téléphone non disponible'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0F1E),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID du propriétaire',
                      style: GoogleFonts.manrope(
                        color: Colors.white38,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      proprietaire['id'] ?? 'Non disponible',
                      style: GoogleFonts.manrope(
                        color: Colors.white54,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: const Color(0xFF090D16),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.white38),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.manrope(
              color: Colors.white54,
              fontSize: 13.sp,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}