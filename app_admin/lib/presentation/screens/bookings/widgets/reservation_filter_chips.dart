import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ReservationFilterChips extends StatelessWidget {
  final List<String> filterOptions;
  final String selectedFilter;
  final Map<String, int> stats;
  final Function(String) onFilterSelected;

  const ReservationFilterChips({
    super.key,
    required this.filterOptions,
    required this.selectedFilter,
    required this.stats,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filterOptions.map((filter) {
          final count = stats[filter] ?? 0;
          final isSelected = selectedFilter == filter;
          Color activeColor = const Color(0xFFFFC107);
          if (filter == 'Confirmé') activeColor = const Color(0xFF10B981);
          if (filter == 'Annulé') activeColor = const Color(0xFFEF4444);
          if (filter == 'En attente') activeColor = const Color(0xFFF59E0B);
          if (filter == 'Terminé') activeColor = const Color(0xFF8B5CF6);

          return Container(
            margin: EdgeInsets.only(right: 12.w),
            child: ChoiceChip(
              label: Text(
                "$filter ($count)",
                style: GoogleFonts.manrope(
                  color: isSelected ? const Color(0xFF090D16) : Colors.white70,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: isSelected,
              selectedColor: activeColor,
              backgroundColor: const Color(0xFF111622),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
                side: BorderSide(
                  color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              onSelected: (_) => onFilterSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}