// lib/presentation/screens/properties/appartement/Bamako/Appartement/CRUD/widgets/apartment_detail_modal/apartment_detail_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../../../../../../../../../../services_appart/apartment_detail_service.dart';
import '../../../../../../../../data/models/detail_appartement/appartement_info.dart';
import '../../../../../../../../data/models/detail_appartement/appartement_role.dart';

import '../../../../../widgets/apartment_detail_modal/apartment_detail_body.dart';
import '../../../../../widgets/apartment_detail_modal/apartment_footer.dart';
import '../../../../../widgets/apartment_detail_modal/apartment_header.dart';
import '../../../../../widgets/apartment_detail_modal/error_dialog.dart';
import '../../../../../widgets/apartment_detail_modal/fullscreen_gallery.dart';
import '../../../../../widgets/apartment_detail_modal/loading_dialog.dart';

class ApartmentDetailModal extends StatefulWidget {
  final Map<String, dynamic> appartement;
  final SupabaseClient supabaseClient;

  const ApartmentDetailModal({
    Key? key,
    required this.appartement,
    required this.supabaseClient,
  }) : super(key: key);

  @override
  State<ApartmentDetailModal> createState() =>
      _ApartmentDetailModalState();
}

class _ApartmentDetailModalState
    extends State<ApartmentDetailModal> {

  // ============================================================
  // ID APPARTEMENT
  // ============================================================

  String get _id =>
      widget.appartement['id']?.toString() ?? '';

  // ============================================================
  // FUTURE UNIQUE
  // ============================================================

  late Future<ApartmentDetailData> _detailFuture;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _logAppartementInfo();

    final service = ApartmentDetailService(
      id: _id,
      client: widget.supabaseClient,
    );

    // IMPORTANT :
    // On lance fetchAll() UNE SEULE FOIS.
    _detailFuture = service.fetchAll();
  }

  // ============================================================
  // LOG
  // ============================================================

  void _logAppartementInfo() {
    debugPrint('═══════════════════════════════════════');
    debugPrint('🏠 MODAL BUILD');
    debugPrint('🏠 ID : "$_id"');
    debugPrint(
      '🏠 Titre : ${widget.appartement["titre"]}',
    );
    debugPrint(
      '🏠 Type ID : ${widget.appartement["id"].runtimeType}',
    );
    debugPrint('═══════════════════════════════════════');
  }

  // ============================================================
  // STATUT
  // ============================================================

  String _getStatusText(String? status) {
    switch (status) {
      case 'en_attente':
        return 'En attente';

      case 'publie':
        return 'Publié';

      case 'refuse':
        return 'Refusé';

      case 'supprime':
        return 'Supprimé';

      default:
        return 'Inconnu';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'en_attente':
        return const Color(0xFFF59E0B);

      case 'publie':
        return const Color(0xFF10B981);

      case 'refuse':
        return const Color(0xFFEF4444);

      case 'supprime':
        return Colors.grey;

      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // FORMAT PRIX
  // ============================================================

  String _formatPrix(String prix) {
    try {
      final number = double.parse(prix);

      return '${number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]} ',
      )} FCFA';
    } catch (e) {
      return '$prix FCFA';
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showSnackBar(
      String message,
      Color color,
      IconData icon,
      ) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 20.h,
          ),
          backgroundColor: color.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.start,
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  // ============================================================
  // PUBLICATION
  // ============================================================

  Future<void> _publishAppartement() async {
    try {
      final db = DatabaseService();

      await db.publishAppartement(_id);

      if (!mounted) return;

      _showSnackBar(
        'Appartement publié avec succès',
        const Color(0xFF10B981),
        Icons.check_circle,
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(
        'Erreur : $e',
        const Color(0xFFEF4444),
        Icons.error,
      );
    }
  }

  // ============================================================
  // REFUS
  // ============================================================

  Future<void> _refuseAppartement() async {
    final TextEditingController motifController =
    TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111622),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        title: Text(
          'Refuser cet appartement',
          style: GoogleFonts.manrope(
            color: Colors.white,
          ),
        ),
        content: TextField(
          controller: motifController,
          maxLines: 3,
          style: GoogleFonts.manrope(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Motif du refus',
            hintStyle: GoogleFonts.manrope(
              color: Colors.white38,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(
                color: Color(0xFFFFC107),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(
              'Annuler',
              style: GoogleFonts.manrope(
                color: Colors.white54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Refuser',
              style: GoogleFonts.manrope(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    final motif = motifController.text.trim();

    motifController.dispose();

    if (confirm != true || motif.isEmpty) {
      return;
    }

    try {
      final db = DatabaseService();

      await db.refuseAppartement(
        _id,
        motif,
      );

      if (!mounted) return;

      _showSnackBar(
        'Appartement refusé avec succès !',
        const Color(0xFFEF4444),
        Icons.check_circle,
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(
        'Erreur : $e',
        const Color(0xFFEF4444),
        Icons.error,
      );
    }
  }

  // GALERIE PLEIN ÉCRAN
  void _openFullscreenGallery(
      List<String> images,
      int initialIndex,
      ) {
    if (images.isEmpty) {
      _showSnackBar(
        'Aucune photo disponible',
        const Color(0xFFEF4444),
        Icons.image_not_supported,
      );

      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => FullscreenGallery(
        images: images,
        initialIndex: initialIndex,
      ),
    );
  }

  // BUILD
  @override
  Widget build(BuildContext context) {

    return FutureBuilder<ApartmentDetailData>(
      future: _detailFuture,

      builder: (context, snapshot) {

        // ERREUR
        if (snapshot.hasError) {
          debugPrint(
            'ERREUR MODAL : ${snapshot.error}',
          );

          return ErrorDialog(
            error: snapshot.error.toString(),
            onClose: () {
              Navigator.pop(context);
            },
          );
        }

        // CHARGEMENT
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const LoadingDialog();
        }

        // AUCUNE DONNÉE
        if (!snapshot.hasData) {
          return ErrorDialog(
            error:
            'Impossible de récupérer les informations de cet appartement.',
            onClose: () {
              Navigator.pop(context);
            },
          );
        }

        // DONNÉES
        final data = snapshot.data!;

        // LOG PHOTOS
        debugPrint('═══════════════════════════════════════');
        debugPrint('🏠 APPARTEMENT : $_id');

        for (int i = 0; i < data.images.length; i++) {

        }


        // INFOS
        AppartementInfo? info;

        if (data.infos.isNotEmpty) {
          try {
            info = AppartementInfo.fromMap(
              data.infos.first,
            );
          } catch (e) {
            debugPrint(
              '❌ Erreur parsing infos : $e',
            );
          }
        }

        // RÔLE
        AppartementRole? role;

        if (data.roles.isNotEmpty) {
          try {
            role = AppartementRole.fromMap(
              data.roles.first,
            );
          } catch (e) {
            debugPrint(
              'Erreur parsing rôle : $e',
            );
          }
        }

        // ============================================================
// ÉQUIPEMENTS (directement depuis autres_equipements)
        final Map<String, bool> equipements = data.equipements;

        // VÉRIFICATION DES DONNÉES
        if (!data.hasData) {
          return ErrorDialog(
            error:
            'Cet appartement n\'a pas d\'informations complètes. Veuillez le mettre à jour.',
            onClose: () {
              Navigator.pop(context);
            },
          );
        }

        // PRIX
        final String prixStr =
            widget.appartement['prix']?.toString() ?? '0';

        final double prix =
            double.tryParse(prixStr) ?? 0.0;

        final String formattedPrix =
        _formatPrix(prix.toString());

        // NOMBRE DE SÉJOUR
        final String nbreSejour =
            widget.appartement['nbre_sejour']
                ?.toString() ??
                '';

        // DIALOG
        return Dialog(
          backgroundColor: Colors.transparent,

          insetPadding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 24.h,
          ),

          child: Container(
            width:
            MediaQuery.of(context).size.width * 0.75,

            height:
            MediaQuery.of(context).size.height * 0.88,

            decoration: BoxDecoration(
              color: const Color(0xFF111622),

              borderRadius:
              BorderRadius.circular(16.r),

              border: Border.all(
                color:
                Colors.white.withValues(alpha: 0.08),
              ),

              boxShadow: [
                BoxShadow(
                  color:
                  Colors.black.withValues(alpha: 0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),

            child: ClipRRect(
              borderRadius:
              BorderRadius.circular(16.r),

              child: Column(
                children: [

                  // HEADER
                  ApartmentHeader(
                    appartement:
                    widget.appartement,

                    getStatusText:
                    _getStatusText,

                    getStatusColor:
                    _getStatusColor,
                  ),

                  // CORPS
                  Expanded(
                    child: ApartmentDetailBody(
                      appartement:
                      widget.appartement,

                      //TOUTES LES PHOTOS
                      images:
                      data.images,

                      info:
                      info,

                      role:
                      role,

                      // Map<String, bool>
                      equipements:
                      equipements,

                      formatPrix:
                      _formatPrix,

                      onImageTap: () {

                        if (data.images.isNotEmpty) {

                          _openFullscreenGallery(
                            data.images,
                            0,
                          );

                        } else {

                          _showSnackBar(
                            'Aucune photo disponible',
                            Colors.orange,
                            Icons.image_not_supported,
                          );

                        }
                      },
                    ),
                  ),

                  // FOOTER
                  ApartmentFooter(
                    formattedPrix:
                    formattedPrix,

                    nbreSejour:
                    nbreSejour.isNotEmpty
                        ? nbreSejour
                        : null,

                    onClose: () {
                      Navigator.pop(context);
                    },

                    onContact: () {
                      Navigator.pop(context);
                    },

                    status:
                    widget.appartement['status']
                        ?.toString(),

                    // PUBLIER
                    onPublish: () async {

                      final confirm =
                      await showDialog<bool>(
                        context: context,

                        builder: (_) =>
                            AlertDialog(
                              backgroundColor:
                              const Color(0xFF111622),

                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12.r),

                                side: BorderSide(
                                  color: Colors.white
                                      .withValues(alpha: 0.1),
                                ),
                              ),

                              title: Text(
                                'Publier cet appartement ?',
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                ),
                              ),

                              content: Text(
                                'Voulez-vous vraiment publier cet appartement ?',
                                style: GoogleFonts.manrope(
                                  color: Colors.white70,
                                ),
                              ),

                              actions: [

                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      false,
                                    );
                                  },

                                  child: Text(
                                    'Annuler',
                                    style: GoogleFonts.manrope(
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      true,
                                    );
                                  },

                                  style:
                                  ElevatedButton.styleFrom(
                                    backgroundColor:
                                    const Color(0xFF10B981),

                                    shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(8.r),
                                    ),
                                  ),

                                  child: Text(
                                    'Publier',
                                    style: GoogleFonts.manrope(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        await _publishAppartement();
                      }
                    },

                    // REFUSER
                    onRefuse:
                    _refuseAppartement,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}