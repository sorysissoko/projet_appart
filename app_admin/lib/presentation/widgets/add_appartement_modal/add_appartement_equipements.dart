import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAppartementEquipements extends StatelessWidget {
  final Map<String, bool> equipements;
  final ValueChanged<String> onEquipementChanged;

  const AddAppartementEquipements({
    Key? key,
    required this.equipements,
    required this.onEquipementChanged,
  }) : super(key: key);

  static const Color _amberColor = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 50,
      runSpacing: 1,
      children: equipements.keys.map((key) {
        return SizedBox(
          width: 200.w,
          child: CheckboxListTile(
            value: equipements[key],
            title: Text(
              key.replaceAll('_', ' '),
              style: GoogleFonts.manrope(
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return _amberColor;
              }
              return Colors.white24;
            }),
            checkColor: const Color(0xFF090D16),
            onChanged: (value) {
              onEquipementChanged(key);
            },
          ),
        );
      }).toList(),
    );
  }
}