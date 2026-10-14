import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/dashboard_data.dart';

class RecentBookings extends StatelessWidget {
  final List<BookingData> bookings;

  const RecentBookings({
    super.key,
    required this.bookings,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.h),
          child: Text(
            'Aucune réservation récente',
            style: GoogleFonts.manrope(
              color: Colors.grey[600],
              fontSize: 15.sp,
            ),
          ),
        ),
      );
    }

    return Column(
      children: bookings.map((booking) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.05),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.propertyName,
                      style: GoogleFonts.manrope(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${booking.city} · ${booking.type}',
                      style: GoogleFonts.manrope(
                        fontSize: 12.sp,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  booking.price,
                  style: GoogleFonts.manrope(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFFFC107),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              _StatusBadge(status: booking.status),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Confirmé':
        bgColor = const Color(0xFF10B981).withValues(alpha: 0.15);
        textColor = const Color(0xFF10B981);
        break;
      case 'En attente':
        bgColor = const Color(0xFFF59E0B).withValues(alpha: 0.15);
        textColor = const Color(0xFFF59E0B);
        break;
      case 'Terminé':
        bgColor = const Color(0xFF8B5CF6).withValues(alpha: 0.15);
        textColor = const Color(0xFF8B5CF6);
        break;
      default:
        bgColor = Colors.white.withValues(alpha: 0.05);
        textColor = Colors.white60;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        status,
        style: GoogleFonts.manrope(
          fontSize: 20.sp,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }
}