import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/update_appartement/update_appartement_viewmodel.dart';
import 'custom_input_decoration.dart';
import 'dark_picker_helper.dart';
import 'shared_widgets.dart';

class RulesSection extends StatelessWidget {
  final UpdateAppartementViewModel viewModel;

  const RulesSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 15.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colonne gauche : Description des règles
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: viewModel.descriptionRegleCtrl,
                  maxLines: 7,
                  style: GoogleFonts.manrope(color: Colors.white),
                  decoration: darkInputDecoration('Description des règles'),
                  validator: viewModel.validateRequired,
                ),
              ),
              SizedBox(width: 30.w),
              // Colonne droite : Heures, Nombre de clients Dropdowns
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    twoFields(
                      _buildTimeField(
                        context,
                        viewModel.heureArriveeCtrl,
                        "Heure d'arrivée",
                        Icons.access_time_rounded,
                      ),
                      _buildTimeField(
                        context,
                        viewModel.heureDepartCtrl,
                        "Heure de départ",
                        Icons.access_time_filled_rounded,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    twoFields(
                      miniNumberField(
                        viewModel.nbreClientCtrl,
                        'Nombre max de clients',
                        viewModel.validateRequired,
                      ),
                      _buildFumeurDropdown(),
                    ),
                    SizedBox(height: 15.h),
                    twoFields(
                      _buildAnimauxDropdown(),
                      _buildFeteDropdown(),
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

  Widget _buildTimeField(
      BuildContext context,
      TextEditingController ctrl,
      String label,
      IconData icon,
      ) {
    return DarkPickerField(
      label: label,
      controller: ctrl,
      icon: icon,
      validator: viewModel.validateRequired,
      onTap: () {
        final initialTime = viewModel.parseTimeOfDay(ctrl.text);
        DarkPickerHelper.selectTime(
          context: context,
          controller: ctrl,
          initialTime: initialTime,
        );
      },
    );
  }

  Widget _buildFumeurDropdown() {
    return _buildDarkDropdown(
      label: "Fumeurs",
      value: viewModel.selectedFumeur,
      items: const [
        DropdownMenuItem(value: 'Fumeurs non acceptés', child: Text('Non acceptés')),
        DropdownMenuItem(value: 'Fumeurs acceptés', child: Text('Acceptés')),
      ],
      onChanged: (value) => viewModel.setSelectedFumeur(value),
    );
  }

  Widget _buildAnimauxDropdown() {
    return _buildDarkDropdown(
      label: "Animaux",
      value: viewModel.selectedAnimaux,
      items: const [
        DropdownMenuItem(value: 'Pas d animaux', child: Text('Pas d\'animaux')),
        DropdownMenuItem(value: 'Animaux acceptés: Chien', child: Text('Chien accepté')),
        DropdownMenuItem(value: 'Animaux acceptés: Chat', child: Text('Chat accepté')),
      ],
      onChanged: (value) => viewModel.setSelectedAnimaux(value),
    );
  }

  Widget _buildFeteDropdown() {
    return _buildDarkDropdown(
      label: "Fête",
      value: viewModel.selectedFete,
      items: const [
        DropdownMenuItem(value: 'Pas de fêtes', child: Text('Pas de fêtes')),
        DropdownMenuItem(value: 'Fêtes acceptées', child: Text('Fêtes acceptées')),
      ],
      onChanged: (value) => viewModel.setSelectedFete,
    );
  }

  Widget _buildDarkDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    // Vérification de sécurité pour le fallback de la valeur
    final validValue = items.any((element) => element.value == value) ? value : null;

    return DropdownButtonFormField<String>(
      decoration: darkInputDecoration(label),
      initialValue: validValue,
      dropdownColor: const Color(0xFF131B2E),
      style: GoogleFonts.manrope(color: Colors.white),
      isExpanded: true,
      items: items,
      onChanged: onChanged,
      validator: (val) => val == null ? 'Ce champ est obligatoire' : null,
    );
  }
}