import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/detail_appartement/appartement_role.dart';

class ApartmentInformation extends StatelessWidget {
  final AppartementRole? role;
  final int? nombreClient;

  const ApartmentInformation({
    Key? key,
    this.role,
    this.nombreClient,
  }) : super(key: key);

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 30.sp,
            color: const Color(0xFFFFC107),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 20.sp,
                  color: Colors.white54,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxCapacity = role?.nombreClient.toString() ??
        nombreClient?.toString() ??
        'Non spécifié';

    final checkIn = role?.heureArrive ?? '14:00';
    final checkOut = role?.heureDepart ?? '12:00';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations complémentaires',
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
            children: [
              _buildInfoRow(
                icon: Icons.people_outline,
                label: 'Capacité d\'accueil',
                value: maxCapacity != 'Non spécifié' ? '$maxCapacity personne(s)' : maxCapacity,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.08),
                  height: 1,
                ),
              ),
              _buildInfoRow(
                icon: Icons.access_time_outlined,
                label: 'Heures d\'Arrivée / Départ',
                value: 'Arrivée dès $checkIn  •  Départ avant $checkOut',
              ),
            ],
          ),
        ),
      ],
    );
  }
}