import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/reservation_helpers.dart';
import 'user_details_dialog.dart';

class ReservationDetailsDialog {
  static void show(
      BuildContext context,
      Map<String, dynamic> reservation,
      VoidCallback onConfirm,
      VoidCallback onRefuse,
      VoidCallback onAnnuler,
      ) {
    final appartement = reservation['appartement'] as Map<String, dynamic>?;
    final locataire = reservation['locataire'] as Map<String, dynamic>?;
    final proprietaire = (reservation['proprietaire'] as Map<String, dynamic>?)
        ?? (appartement?['proprietaire'] as Map<String, dynamic>?);
    final status = reservation['statut'] as String? ?? 'en_attente';

    //Conversion explicite en double avec tryParse
    final prixTotal = double.tryParse(reservation['prix_total']?.toString() ?? '0') ?? 0.0;
    final prixProprietaire = double.tryParse(reservation['prix_proprietaire']?.toString() ?? '0') ?? 0.0;
    final fraisService = double.tryParse(reservation['frais_service']?.toString() ?? '0') ?? 0.0;
    final reduction = double.tryParse(reservation['reduction']?.toString() ?? '0') ?? 0.0;

    final adulte = reservation['adulte'] ?? 1;
    final enfant = reservation['enfant'] ?? 0;
    final momentPaiement = reservation['moment_paiement'] ?? 'arrivee';
    final methodePaiement = reservation['methode_paiement'] ?? 'Non spécifié';
    final message = reservation['message'] ?? '';

    final nombreNuits = ReservationHelpers.calculateNights(
      DateTime.parse(reservation['date_debut'].toString()),
      DateTime.parse(reservation['date_fin'].toString()),
    );

    final prixParNuit = double.tryParse(appartement?['prix']?.toString() ?? '0') ?? 0.0;
    final prixParNuitRed = prixTotal > 0 && nombreNuits > 0 ? prixTotal / nombreNuits : 0.0;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 700.w,
          constraints: BoxConstraints(maxHeight: 0.9.sh),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFF111622),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(status, dialogContext),
                Divider(color: Colors.white.withValues(alpha: 0.1)),
                SizedBox(height: 12.h),
                _buildUsersSection(dialogContext, locataire, proprietaire),
                SizedBox(height: 16.h),
                _buildPropertySection(appartement, reservation, nombreNuits),
                SizedBox(height: 16.h),
                _buildPriceSection(
                  adulte,
                  enfant,
                  methodePaiement,
                  momentPaiement,
                  message,
                  prixParNuit,
                  nombreNuits,
                  prixParNuitRed,
                  reduction,
                  prixProprietaire,
                  fraisService,
                  prixTotal,
                ),
                SizedBox(height: 20.h),
                _buildActions(status, onConfirm, onRefuse, onAnnuler),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildHeader(String status, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              '📋 Détails de la réservation',
              style: GoogleFonts.manrope(color: Colors.white, fontSize: 30.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 50.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: ReservationHelpers.getStatusColor(status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                ReservationHelpers.getStatusText(status),
                style: GoogleFonts.manrope(
                  color: ReservationHelpers.getStatusColor(status),
                  fontWeight: FontWeight.w800,
                  fontSize: 15.sp,
                ),
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.close, color: Colors.white60),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  static Widget _buildUsersSection(
      BuildContext context,
      Map<String, dynamic>? locataire,
      Map<String, dynamic>? proprietaire,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserCard(
          context,
          '👤 Locataire',
          locataire,
          const Color(0xFFFFC107),
              () {
            if (locataire != null) {
              UserDetailsDialog.showLocataireDetails(context, locataire);
            }
          },
        ),
        SizedBox(width: 12.w),
        _buildUserCard(
          context,
          '🏢 Propriétaire',
          proprietaire,
          const Color(0xFF10B981),
              () {
            if (proprietaire != null) {
              UserDetailsDialog.showProprietaireDetails(context, proprietaire);
            }
          },
        ),
      ],
    );
  }

  static Widget _buildUserCard(
      BuildContext context,
      String title,
      Map<String, dynamic>? user,
      Color color,
      VoidCallback onView,
      ) {
    return Expanded(
      flex: 1,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0F1E),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.manrope(color: color, fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: color,
                  child: Text(
                    user != null
                        ? '${user['prenom']?[0] ?? ''}${user['nom']?[0] ?? ''}'
                        : '?',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF090D16),
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user != null
                            ? '${user['prenom'] ?? ''} ${user['nom'] ?? ''}'
                            : 'Utilisateur inconnu',
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (user != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          user['email'] ?? '',
                          style: GoogleFonts.manrope(color: Colors.white54, fontSize: 14.sp, letterSpacing: 0.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user['telephone'] ?? '',
                          style: GoogleFonts.manrope(color: Colors.white54, fontSize: 14.sp, letterSpacing: 0.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            if (user != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: TextButton.icon(
                  onPressed: onView,
                  icon: Icon(Icons.visibility, color: color, size: 20.sp),
                  label: Text(
                    'Voir',
                    style: GoogleFonts.manrope(
                      color: color,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPropertySection(
      Map<String, dynamic>? appartement,
      Map<String, dynamic> reservation,
      int nombreNuits,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInfoCard(
            '🏠 Propriété',
            [
              Text(
                appartement?['titre'] ?? 'Titre non disponible',
                style: GoogleFonts.manrope(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4.h),
              Text(
                '${appartement?['ville'] ?? ''} - ${appartement?['adresse'] ?? ''}',
                style: GoogleFonts.manrope(color: Colors.white54, fontSize: 16.sp),
              ),
              Text(
                'Type: ${appartement?['type'] ?? ''}',
                style: GoogleFonts.manrope(color: Colors.white54, fontSize: 14.sp),
              ),
              if (appartement?['prix'] != null)
                Text(
                  'Prix/nuit: ${ReservationHelpers.formatPrix((appartement!['prix'] as num?)?.toDouble().toString() ?? '0')}',
                  style: GoogleFonts.manrope(color: Colors.white54, fontSize: 18.sp, fontWeight: FontWeight.w800),
                ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildInfoCard(
            '📅 Séjour',
            [
              Text(
                'Arrivée: ${ReservationHelpers.formatDate(reservation['date_debut'])}',
                style: GoogleFonts.manrope(color: Colors.white, fontSize: 17.sp),
              ),
              Text(
                'Départ: ${ReservationHelpers.formatDate(reservation['date_fin'])}',
                style: GoogleFonts.manrope(color: Colors.white, fontSize: 17.sp),
              ),
              Container(
                margin: EdgeInsets.only(top: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nombre de nuits',
                      style: GoogleFonts.manrope(color: Colors.white70, fontSize: 14.sp),
                    ),
                    Text(
                      '$nombreNuits nuits',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFFFC107),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1E),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(color: const Color(0xFFFFC107), fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          ...children,
        ],
      ),
    );
  }

  static Widget _buildPriceSection(
      int adulte,
      int enfant,
      String methodePaiement,
      String momentPaiement,
      String message,
      double prixParNuit,
      int nombreNuits,
      double prixParNuitRed,
      double reduction,
      double prixProprietaire,
      double fraisService,
      double prixTotal,
      ) {
    return _buildInfoCard(
      '💰 Détails de la réservation',
      [
        Row(
          children: [
            _buildStatCard('Adultes', '$adulte'),
            SizedBox(width: 8.w),
            _buildStatCard('Enfants', '$enfant'),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Méthode de paiement', style: GoogleFonts.manrope(color: Colors.white70, fontSize: 15.sp)),
                    Text(methodePaiement, style: GoogleFonts.manrope(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Moment de paiement', style: GoogleFonts.manrope(color: Colors.white70, fontSize: 15.sp)),
                    Text(
                      ReservationHelpers.getMomentPaiementText(momentPaiement),
                      style: GoogleFonts.manrope(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (message.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Message', style: GoogleFonts.manrope(color: Colors.white38, fontSize: 11.sp)),
                Text(message, style: GoogleFonts.manrope(color: Colors.white70, fontSize: 13.sp)),
              ],
            ),
          ),
        ],
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              _buildPriceRow('Prix par nuit', ReservationHelpers.formatPrix(prixParNuit.toStringAsFixed(0))),
              _buildPriceRow('Nombre de nuits', '$nombreNuits nuit${nombreNuits > 1 ? 's' : ''}'),
              _buildPriceRow('Prix par nuit après réduction', ReservationHelpers.formatPrix(prixParNuitRed.toStringAsFixed(0))),
              Divider(color: Colors.white.withValues(alpha: 0.05), height: 12.h),
              _buildPriceRow('Réduction', '-${ReservationHelpers.formatPrix(reduction.toStringAsFixed(0))}', color: const Color(0xFF10B981)),
              Divider(color: Colors.white.withValues(alpha: 0.05), height: 12.h),
              _buildPriceRow('Frais propriétaire (net)', ReservationHelpers.formatPrix(prixProprietaire.toStringAsFixed(0)), isBold: true),
              _buildPriceRow('Frais de service (net)', ReservationHelpers.formatPrix(fraisService.toStringAsFixed(0)), isBold: true, color: const Color(0xFFFFC107)),
              Divider(color: Colors.white.withValues(alpha: 0.1), height: 12.h),
              _buildPriceRow('Prix total', ReservationHelpers.formatPrix(prixTotal.toStringAsFixed(0)), isBold: true, color: Colors.white, fontSize: 28.sp),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.manrope(color: Colors.white70, fontSize: 15.sp)),
            Text(value, style: GoogleFonts.manrope(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  static Widget _buildPriceRow(String label, String value, {bool isBold = false, Color? color, double? fontSize}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              color: color ?? Colors.white54,
              fontSize: fontSize ?? 20.sp,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.manrope(
              color: color ?? Colors.white,
              fontSize: fontSize ?? 22.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildActions(
      String status,
      VoidCallback onConfirm,
      VoidCallback onRefuse,
      VoidCallback onAnnuler,
      ) {
    if (status == 'en_attente') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onConfirm,
              icon: const Icon(Icons.check, size: 20),
              label: const Text('Confirmer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onRefuse,
              icon: const Icon(Icons.close, size: 20),
              label: const Text('Refuser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
          ),
        ],
      );
    }

    if (status == 'confirmee') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onAnnuler,
          icon: const Icon(Icons.cancel, size: 20),
          label: const Text('Annuler la réservation'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}