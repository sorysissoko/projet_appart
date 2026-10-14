import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/add_appartement/add_appartement_validators.dart';

class AddAppartementRules extends StatelessWidget {
  final TextEditingController descriptionRegleCtrl;
  final TextEditingController heureArriveeCtrl;
  final TextEditingController heureDepartCtrl;
  final TextEditingController nbreClientCtrl;
  final TextEditingController fumeurCtrl;
  final TextEditingController animauxCtrl;
  final TextEditingController feteCtrl;

  const AddAppartementRules({
    Key? key,
    required this.descriptionRegleCtrl,
    required this.heureArriveeCtrl,
    required this.heureDepartCtrl,
    required this.nbreClientCtrl,
    required this.fumeurCtrl,
    required this.animauxCtrl,
    required this.feteCtrl,
  }) : super(key: key);

  static const Color _amberColor = Color(0xFFFFC107);
  static const Color _inputTextColor = Color(0xFFB8B8B8);

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.manrope(
        color: Colors.white60,
        fontSize: 22.sp,
      ),
      floatingLabelStyle: GoogleFonts.manrope(
        color: _amberColor,
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.transparent,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.white30, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: _amberColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Widget _twoFields(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 15),
        Expanded(child: right),
      ],
    );
  }

  Widget _miniNumberField(TextEditingController controller, String hint) {
    return Container(
      width: 120.w,
      margin: EdgeInsets.only(right: 20.w),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: GoogleFonts.manrope(
          color: _inputTextColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
        decoration: _inputDecoration(hint),
        validator: AddAppartementValidators.validateNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: descriptionRegleCtrl,
              style: GoogleFonts.manrope(
                color: _inputTextColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 7,
              decoration: _inputDecoration('Description'),
              validator: (value) => AddAppartementValidators.validateMinLength(value, 10, 'Description'),
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _twoFields(
                  TextFormField(
                    controller: heureArriveeCtrl,
                    style: GoogleFonts.manrope(
                      color: _inputTextColor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    readOnly: true,
                    decoration: _inputDecoration("Heure d'arrivée"),
                    validator: (value) => AddAppartementValidators.validateTime(value, 'Heure d\'arrivée'),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        heureArriveeCtrl.text =
                        "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                      }
                    },
                  ),
                  TextFormField(
                    controller: heureDepartCtrl,
                    style: GoogleFonts.manrope(
                      color: _inputTextColor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    readOnly: true,
                    decoration: _inputDecoration("Heure de départ"),
                    validator: (value) => AddAppartementValidators.validateTime(value, 'Heure de départ'),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        heureDepartCtrl.text =
                        "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                      }
                    },
                  ),
                ),
                const SizedBox(height: 15),
                _twoFields(
                  _miniNumberField(nbreClientCtrl, 'Nombre client'),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration("Fumeurs"),
                    icon: const Icon(Icons.arrow_drop_down, color: _amberColor),
                    initialValue: fumeurCtrl.text.isEmpty ? null : fumeurCtrl.text,
                    isExpanded: true,
                    style: GoogleFonts.manrope(
                      color: _inputTextColor,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return ['Fumeurs non acceptés', 'Fumeurs acceptés'].map<Widget>((String value) {
                        return Text(
                          value == 'Fumeurs non acceptés' ? 'Non acceptés' : 'Acceptés',
                          style: GoogleFonts.manrope(
                            color: _inputTextColor,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList();
                    },
                    items: [
                      DropdownMenuItem(value: 'Fumeurs non acceptés', child: Text('Non acceptés', style: GoogleFonts.manrope(color: Colors.black87))),
                      DropdownMenuItem(value: 'Fumeurs acceptés', child: Text('Acceptés', style: GoogleFonts.manrope(color: Colors.black87))),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        fumeurCtrl.text = newValue;
                      }
                    },
                    validator: (value) => AddAppartementValidators.validateRequired(value, 'Fumeurs'),
                  ),
                ),
                const SizedBox(height: 15),
                _twoFields(
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration("Animaux"),
                    icon: const Icon(Icons.arrow_drop_down, color: _amberColor),
                    initialValue: animauxCtrl.text.isEmpty ? null : animauxCtrl.text,
                    isExpanded: true,
                    style: GoogleFonts.manrope(
                      color: _inputTextColor,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return ['Pas d animaux', 'Animaux acceptés: Chien', 'Animaux acceptés: Chat'].map<Widget>((String value) {
                        String label = "Pas d'animaux";
                        if (value == 'Animaux acceptés: Chien') label = 'Chien accepté';
                        if (value == 'Animaux acceptés: Chat') label = 'Chat accepté';
                        return Text(
                          label,
                          style: GoogleFonts.manrope(
                            color: _inputTextColor,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList();
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'Pas d animaux',
                        child: Text('Pas d animaux', style: GoogleFonts.manrope(color: Colors.black87)),
                      ),
                      DropdownMenuItem(
                        value: 'Animaux acceptés: Chien',
                        child: Text('Animaux acceptés: Chien', style: GoogleFonts.manrope(color: Colors.black87)),
                      ),
                      DropdownMenuItem(
                        value: 'Animaux acceptés: Chat',
                        child: Text('Animaux acceptés: Chat', style: GoogleFonts.manrope(color: Colors.black87)),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        animauxCtrl.text = newValue;
                      }
                    },
                    validator: (value) => AddAppartementValidators.validateRequired(value, 'Animaux'),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration("Fête"),
                    icon: const Icon(Icons.arrow_drop_down, color: _amberColor),
                    initialValue: feteCtrl.text.isEmpty ? null : feteCtrl.text,
                    isExpanded: true,
                    style: GoogleFonts.manrope(
                      color: _inputTextColor,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return ['Pas de fetes', 'Fêtes acceptees'].map<Widget>((String value) {
                        return Text(
                          value == 'Pas de fetes' ? 'Pas de fêtes' : 'Fêtes acceptées',
                          style: GoogleFonts.manrope(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList();
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'Pas de fetes',
                        child: Text('Pas de fêtes', style: GoogleFonts.manrope(color: Colors.black87)),
                      ),
                      DropdownMenuItem(
                        value: 'Fêtes acceptees',
                        child: Text('Fêtes acceptées', style: GoogleFonts.manrope(color: Colors.black87)),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        feteCtrl.text = newValue;
                      }
                    },
                    validator: (value) => AddAppartementValidators.validateRequired(value, 'Fêtes'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}