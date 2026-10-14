import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../data/models/update_appartement/update_appartement_viewmodel.dart';
import '../add_appartement_modal/add_appartement_section.dart';
import '../apartment_detail_modal/loading_dialog.dart';
import 'disponibility_section.dart';
import 'action_buttons.dart';
import 'characteristics_section.dart';
import 'equipments_section.dart';
import 'information_section.dart';
import 'rules_section.dart';

class UpdateAppartementDialog extends StatelessWidget {
  final Map<String, dynamic> appartement;


  const UpdateAppartementDialog({
    super.key,
    required this.appartement,
  });

  @override
  Widget build(BuildContext context) {
    const primaryAccent = Color(0xFFFFC107);

    return ChangeNotifierProvider(
      create: (_) => UpdateAppartementViewModel(appartementData: appartement),
      child: Dialog(
        backgroundColor: const Color(0xFF090D16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: SizedBox(
          width: 1100.w,
          child: Consumer<UpdateAppartementViewModel>(
            builder: (context, viewModel, child) {
              final state = viewModel.state;

              // 1. État de Chargement
              if (state.isLoading) {
                return const LoadingDialog();
              }

              // 2. État d'Erreur
              if (state.errorMessage != null && !state.dataLoaded) {
                return Padding(
                  padding: EdgeInsets.all(30.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 60.r,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Fermer'),
                      ),
                    ],
                  ),
                );
              }

              // 3. Formulaire Principal
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(24.w),
                child: Form(
                  key: viewModel.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Titre principal
                      Text(
                        'Modifier l\'appartement',
                        style: GoogleFonts.manrope(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 30.h),

                      // Section Informations Générales
                      InformationSection(
                        viewModel: viewModel,
                        residences: viewModel.residences,
                      ),

                      const Divider(height: 40, color: Colors.white10),

                      // Section Caractéristiques (Contient son propre titre centré)
                      CharacteristicsSection(viewModel: viewModel),

                      const Divider(height: 40, color: Colors.white10),

                      // Section Règles
                      AddAppartementSection(
                        title: 'Règles',
                        child: RulesSection(viewModel: viewModel),
                      ),

                      // Section Disponibilités
                      AddAppartementSection(
                        title: 'Dates de disponibilité',
                        child: DisposabilitySection(viewModel: viewModel),
                      ),

                      // Section Équipements
                      AddAppartementSection(
                        title: 'Équipements',
                        child: EquipmentsSection(viewModel: viewModel),
                      ),

                      SizedBox(height: 20.h),

                      // Boutons d'action (Annuler / Modifier)
                      ActionButtons(viewModel: viewModel),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}