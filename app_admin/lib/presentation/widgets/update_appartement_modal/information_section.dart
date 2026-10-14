import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/update_appartement/update_appartement_viewmodel.dart';
import 'custom_input_decoration.dart';
import 'shared_widgets.dart';

class InformationSection extends StatelessWidget {
  final UpdateAppartementViewModel viewModel;

  /// Liste des résidences appartenant au propriétaire.
  ///
  /// Chaque élément doit contenir au minimum :
  /// {
  ///   'id': '...',
  ///   'nom': '...',
  ///   'ville': '...',
  ///   'adresse': '...',
  ///   'localisation': '...',
  ///   'status': 'validee'
  /// }
  final List<Map<String, dynamic>> residences;

  const InformationSection({
    super.key,
    required this.viewModel,
    required this.residences,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // COLONNE GAUCHE : INFORMATIONS PRINCIPALES
          // ======================================================

          Expanded(
            flex: 3,
            child: Column(
              children: [
                // ------------------------------------------------
                // NOM + TYPE
                // ------------------------------------------------

                twoFields(
                  TextFormField(
                    controller: viewModel.titreCtrl,
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                    ),
                    decoration: darkInputDecoration(
                      "Nom de l'appartement",
                    ),
                    validator:
                    viewModel.validateRequired,
                  ),
                  _buildTypeDropdown(),
                ),

                SizedBox(height: 15.h),

                // ------------------------------------------------
                // RÉSIDENCE
                // ------------------------------------------------

                _buildResidenceDropdown(),

                SizedBox(height: 15.h),

                // ------------------------------------------------
                // NOMBRE DE SÉJOUR + PRIX
                // ------------------------------------------------

                twoFields(
                  _buildNbreSejourDropdown(),
                  TextFormField(
                    controller:
                    viewModel.prixController,
                    keyboardType:
                    TextInputType.number,
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                    ),
                    decoration:
                    darkInputDecoration(
                      'Prix (F CFA)',
                    ),
                    validator:
                    viewModel.validatePrix,
                  ),
                ),

                SizedBox(height: 15.h),

                // ------------------------------------------------
                // INFORMATIONS DE LA RÉSIDENCE
                // ------------------------------------------------

                _buildResidenceDetails(),
              ],
            ),
          ),

          SizedBox(width: 30.w),

          // ======================================================
          // COLONNE DROITE : DESCRIPTION
          // ======================================================

          Expanded(
            flex: 2,
            child: TextFormField(
              controller:
              viewModel.descriptionCtrl,
              maxLines: 7,
              style: GoogleFonts.manrope(
                color: Colors.white,
              ),
              decoration:
              darkInputDecoration(
                'Description',
              ),
              validator:
              viewModel.validateDescription,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RÉSIDENCE
  // ============================================================

  Widget _buildResidenceDropdown() {
    final validResidence =
    residences.any(
          (residence) =>
      residence['id']?.toString() ==
          viewModel.selectedResidenceId,
    );

    final currentValue =
    validResidence
        ? viewModel.selectedResidenceId
        : null;

    return DropdownButtonFormField<String>(
      decoration: darkInputDecoration(
        'Résidence',
      ),
      initialValue: currentValue,
      dropdownColor:
      const Color(0xFF131B2E),
      style: GoogleFonts.manrope(
        color: Colors.white,
      ),
      iconEnabledColor:
      Colors.white70,
      isExpanded: true,
      items: residences.map(
            (residence) {
          final id =
          residence['id']?.toString();

          final nom =
              residence['nom']
                  ?.toString() ??
                  'Résidence sans nom';

          final ville =
              residence['ville']
                  ?.toString() ??
                  '';

          return DropdownMenuItem<String>(
            value: id,
            child: Text(
              ville.isEmpty
                  ? nom
                  : '$nom — $ville',
              overflow:
              TextOverflow.ellipsis,
            ),
          );
        },
      ).toList(),
      onChanged: (value) {
        if (value == null) {
          viewModel.clearResidence();
          return;
        }

        final residence =
        residences.firstWhere(
              (element) =>
          element['id']?.toString() ==
              value,
          orElse: () => {},
        );

        if (residence.isEmpty) {
          return;
        }

        viewModel.setResidence(
          residenceId: value,
          nom: residence['nom']?.toString(),
          ville:
          residence['ville']?.toString(),
          adresse:
          residence['adresse']
              ?.toString(),
          localisation:
          residence['localisation']
              ?.toString(),
        );
      },
      validator:
          (_) => viewModel
          .validateResidence(null),
    );
  }

  // ============================================================
  // INFORMATIONS DE LA RÉSIDENCE
  // ============================================================

  Widget _buildResidenceDetails() {
    final hasResidence =
        viewModel.selectedResidenceId !=
            null &&
            viewModel.selectedResidenceId!
                .trim()
                .isNotEmpty;

    if (!hasResidence) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFF131B2E),
          borderRadius:
          BorderRadius.circular(10.r),
          border: Border.all(
            color: Colors.white12,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white54,
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Sélectionnez une résidence pour afficher son adresse et sa ville.',
                style:
                GoogleFonts.manrope(
                  color: Colors.white60,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius:
        BorderRadius.circular(10.r),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------
          // TITRE
          // ------------------------------------------------------

          Row(
            children: [
              Icon(
                Icons.apartment,
                color: Colors.white70,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  viewModel
                      .selectedResidenceName
                      .isNotEmpty
                      ? viewModel
                      .selectedResidenceName
                      : 'Résidence sélectionnée',
                  style:
                  GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // ------------------------------------------------------
          // VILLE
          // ------------------------------------------------------

          _buildResidenceInfoRow(
            icon: Icons.location_city,
            label: 'Ville',
            value:
            viewModel.selectedResidenceVille,
          ),

          SizedBox(height: 8.h),

          // ------------------------------------------------------
          // ADRESSE
          // ------------------------------------------------------

          _buildResidenceInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Adresse',
            value:
            viewModel.selectedResidenceAdresse,
          ),

          // ------------------------------------------------------
          // LOCALISATION
          // ------------------------------------------------------

          if (viewModel
              .selectedResidenceLocalisation
              .isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildResidenceInfoRow(
              icon: Icons.map_outlined,
              label: 'Localisation',
              value:
              viewModel
                  .selectedResidenceLocalisation,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResidenceInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white54,
          size: 18.sp,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label : ',
                  style:
                  GoogleFonts.manrope(
                    color: Colors.white54,
                    fontSize: 12.sp,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: value.isNotEmpty
                      ? value
                      : 'Non renseigné',
                  style:
                  GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TYPE
  // ============================================================

  Widget _buildTypeDropdown() {
    return _buildDarkDropdown(
      label: "Type",
      value: viewModel.typeCtrl
          .text
          .isEmpty
          ? null
          : viewModel.typeCtrl.text,
      items: const [
        DropdownMenuItem(
          value: 'Appart',
          child: Text('Appartement'),
        ),
        DropdownMenuItem(
          value: 'Villa',
          child: Text('Villa'),
        ),
        DropdownMenuItem(
          value: 'Maison',
          child: Text('Maison'),
        ),
        DropdownMenuItem(
          value: 'Bureau',
          child: Text('Bureau'),
        ),
        DropdownMenuItem(
          value: 'Hôtel',
          child: Text('Hôtel'),
        ),
      ],
      onChanged: viewModel.setType,
      validator:
      viewModel.validateRequired,
    );
  }

  // ============================================================
  // NOMBRE DE SÉJOUR
  // ============================================================

  Widget _buildNbreSejourDropdown() {
    return _buildDarkDropdown(
      label: "Nombre de séjour",
      value: viewModel
          .nbreSejourCtrl
          .text
          .isEmpty
          ? null
          : viewModel
          .nbreSejourCtrl
          .text,
      items: const [
        DropdownMenuItem(
          value: 'nuit',
          child: Text('nuit'),
        ),
        DropdownMenuItem(
          value: 'mois',
          child: Text('mois'),
        ),
      ],
      onChanged: viewModel.setType,
      validator:
      viewModel.validateRequired,
    );
  }

  // ============================================================
  // DROPDOWN SOMBRE RÉUTILISABLE
  // ============================================================

  Widget _buildDarkDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>>
    items,
    required ValueChanged<String?>
    onChanged,
    required String? Function(String?)
    validator,
  }) {
    final validValue =
    items.any(
          (element) =>
      element.value == value,
    )
        ? value
        : null;

    return DropdownButtonFormField<String>(
      decoration:
      darkInputDecoration(label),
      initialValue: validValue,
      dropdownColor:
      const Color(0xFF131B2E),
      style: GoogleFonts.manrope(
        color: Colors.white,
      ),
      iconEnabledColor:
      Colors.white70,
      isExpanded: true,
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}