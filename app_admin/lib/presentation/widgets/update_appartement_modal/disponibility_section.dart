import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/update_appartement/update_appartement_viewmodel.dart';
import '../../screens/properties/appartement/CRUD/update/update_appartement_viewmodel.dart';
import 'dark_picker_helper.dart';

class DisposabilitySection extends StatelessWidget {
  final UpdateAppartementViewModel viewModel;

  const DisposabilitySection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Période de disponibilité',
          style: GoogleFonts.manrope(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15.h),
        Row(
          children: [
            Expanded(
              child: DarkPickerField(
                label: 'Date de début',
                controller: viewModel.dateDebutCtrl,
                icon: Icons.calendar_today_rounded,
                validator: viewModel.validateRequired,
                onTap: () {
                  final initial = DateService.parseFromDisplay(viewModel.dateDebutCtrl.text);
                  DarkPickerHelper.selectDate(
                    context: context,
                    controller: viewModel.dateDebutCtrl,
                    initialDate: initial,
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: DarkPickerField(
                label: 'Date de fin',
                controller: viewModel.dateFinCtrl,
                icon: Icons.event_rounded,
                validator: viewModel.validateRequired,
                onTap: () {
                  final initial = DateService.parseFromDisplay(viewModel.dateFinCtrl.text);
                  DarkPickerHelper.selectDate(
                    context: context,
                    controller: viewModel.dateFinCtrl,
                    initialDate: initial,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}