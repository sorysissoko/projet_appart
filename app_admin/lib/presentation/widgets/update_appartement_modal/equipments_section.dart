import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/update_appartement/update_appartement_viewmodel.dart';


class EquipmentsSection extends StatelessWidget {
  final UpdateAppartementViewModel viewModel;

  const EquipmentsSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    const Color darkYellow = Color(0xFFD4A017);

    return Column(
      children: [
        Wrap(
          spacing: 5,
          runSpacing: 1,
          children: viewModel.equipements.keys.map((key) {
            final isSelected = viewModel.equipements[key] ?? false;
            return SizedBox(
              width: 220,
              child: CheckboxListTile(
                value: isSelected,
                title: Text(
                  key.replaceAll('_', ' '),
                  style: GoogleFonts.manrope(
                    color: isSelected ? darkYellow : Colors.white70,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: isSelected ? 20.sp : 17.sp,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: darkYellow,
                checkColor: Colors.black,
                side: const BorderSide(color: Colors.white30),
                onChanged: (value) {
                  viewModel.toggleEquipement(key, value ?? false);
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}