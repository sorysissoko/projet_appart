// lib/presentation/screens/properties/appartement/update/widgets/characteristics_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/update_appartement/update_appartement_viewmodel.dart';
import 'shared_widgets.dart';

class CharacteristicsSection extends StatelessWidget {
  final UpdateAppartementViewModel viewModel;

  const CharacteristicsSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          spacing: 20.w,
          runSpacing: 10.h,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            miniNumberField(viewModel.chambreCtrl, 'Chambre', viewModel.validateRequired),
            miniNumberField(viewModel.salonCtrl, 'Salon', viewModel.validateRequired),
            miniNumberField(viewModel.doucheCtrl, 'Douche', viewModel.validateRequired),
            miniNumberField(viewModel.cuisineCtrl, 'Cuisine', viewModel.validateRequired),
            miniNumberField(viewModel.etageCtrl, 'Étage', viewModel.validateRequired),
            miniNumberField(viewModel.tailleCtrl, 'Taille (m²)', viewModel.validateRequired),
          ],
        ),
        SizedBox(height: 20.h),

        // Options sous forme de Chips Modernes centrés
        ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final options = [
              (
              label: 'Service inclus',
              icon: Icons.electric_bolt_rounded,
              value: viewModel.serviceInclus,
              onChanged: viewModel.setServiceInclus,
              ),
              (
              label: 'Internet',
              icon: Icons.wifi,
              value: viewModel.internet,
              onChanged: viewModel.setInternet,
              ),
              (
              label: 'Stationnement',
              icon: Icons.directions_car_outlined,
              value: viewModel.stationnement,
              onChanged: viewModel.setStationnement,
              ),
              (
              label: 'Meublé',
              icon: Icons.chair_outlined,
              value: viewModel.meuble,
              onChanged: viewModel.setMeuble,
              ),
              (
              label: 'Climatisation',
              icon: Icons.ac_unit,
              value: viewModel.climatisation,
              onChanged: viewModel.setClimatisation,
              ),
            ];

            return Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              alignment: WrapAlignment.center, // Centrage horizontal des chips
              crossAxisAlignment: WrapCrossAlignment.center,
              children: options.map((opt) {
                return _buildOptionChip(
                  label: opt.label,
                  icon: opt.icon,
                  isSelected: opt.value,
                  onTap: () => opt.onChanged(!opt.value),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  /// Chip Minimaliste et Interactif
  Widget _buildOptionChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const primaryColor = Color(0xFFFFC107); // Ambre

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.15)
                  : const Color(0xFF131B2E),
              borderRadius: BorderRadius.circular(25.r),
              border: Border.all(
                color: isSelected ? primaryColor : Colors.white12,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : icon,
                  size: 20.r,
                  color: isSelected ? primaryColor : Colors.white54,
                ),
                SizedBox(width: 5.w),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 18.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}