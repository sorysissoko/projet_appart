import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/reservation_helpers.dart';

class ReservationListItem extends StatelessWidget {
  final Map<String, dynamic> reservation;
  final VoidCallback onTapDetails;
  final VoidCallback onTapConfirm;
  final VoidCallback onTapRefuse;
  final VoidCallback onTapAnnuler;

  const ReservationListItem({
    super.key,
    required this.reservation,
    required this.onTapDetails,
    required this.onTapConfirm,
    required this.onTapRefuse,
    required this.onTapAnnuler,
  });

  @override
  Widget build(BuildContext context) {
    final status = reservation['statut'] as String? ?? 'en_attente';
    final appartement = reservation['appartement'] as Map<String, dynamic>?;
    final locataire = reservation['locataire'] as Map<String, dynamic>?;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appartement?['titre'] ?? 'Sans titre',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '- ${locataire?['prenom'] ?? ''} ${locataire?['nom'] ?? ''} -',
                        style: GoogleFonts.manrope(
                          color: Colors.white54,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '${ReservationHelpers.formatDate(reservation['date_debut'])} → ${ReservationHelpers.formatDate(reservation['date_fin'])} • ${ReservationHelpers.calculateNights(
                    DateTime.parse(reservation['date_debut'].toString()),
                    DateTime.parse(reservation['date_fin'].toString()),
                  )} nuits',
                  style: GoogleFonts.manrope(
                    color: Colors.white38,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  '${ReservationHelpers.formatPrix(reservation['prix_total']?.toString() ?? '0')} • ${(reservation['adulte'] ?? 0) + (reservation['enfant'] ?? 0)} personnes',
                  style: GoogleFonts.manrope(
                    color: Colors.white38,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: ReservationHelpers.getStatusColor(status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  ReservationHelpers.getStatusText(status),
                  style: GoogleFonts.manrope(
                    color: ReservationHelpers.getStatusColor(status),
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white60),
                color: const Color(0xFF111622),
                onSelected: (value) {
                  switch (value) {
                    case 'detail':
                      onTapDetails();
                      break;
                    case 'confirmer':
                      onTapConfirm();
                      break;
                    case 'refuser':
                      onTapRefuse();
                      break;
                    case 'annuler':
                      onTapAnnuler();
                      break;
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'detail',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white, size: 20.sp),
                        SizedBox(width: 12.w),
                        Text(
                          'Détails',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (status == 'en_attente') ...[
                    PopupMenuItem(
                      value: 'confirmer',
                      child: Text('Confirmer', style: GoogleFonts.manrope(color: Colors.green)),
                    ),
                     PopupMenuItem(
                      value: 'refuser',
                      child: Text('Refuser', style: GoogleFonts.manrope(color: Colors.red)),
                    ),
                  ],
                  if (status == 'confirmee')
                    PopupMenuItem(
                      value: 'annuler',
                      child: Row(
                        children: [
                          Icon(Icons.dangerous_outlined, color: Colors.red, size: 20.sp),
                          SizedBox(width: 12.w),
                          Text(
                            'Annuler',
                            style: GoogleFonts.manrope(
                              color: Colors.red,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}