import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service/database_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:service/service_locator.dart';
import 'package:intl/intl.dart';

import '../../widgets/main_layout.dart';
import 'utils/reservation_helpers.dart';
import 'widgets/reservation_filter_chips.dart';
import 'widgets/reservation_details_dialog.dart';
import 'widgets/reservation_search_dialog.dart';

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({super.key});

  @override
  State<ReservationListScreen> createState() =>
      _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {

  // VARIABLES
  List<Map<String, dynamic>> reservations = [];
  List<Map<String, dynamic>> filteredReservations = [];

  String selectedFilter = 'Toutes';

  bool isFetching = true;

  final List<String> filterOptions = [
    'Toutes',
    'En attente',
    'Confirmé',
    'Annulé',
    'Terminé',
  ];

  final DatabaseService _dbService = ServiceLocator.database;

  // INIT
  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  // CHARGEMENT DES RÉSERVATIONS
  Future<void> _fetchReservations() async {
    if (!mounted) return;

    setState(() {
      isFetching = true;
    });

    try {
      debugPrint('🔄 Chargement des réservations...');

      final response = await _dbService.supabase
          .from('reservations')
          .select('''
          *,

          appartement:appartements!reservations_appartement_id_fkey (
            id,
            titre,
            description,
            type,
            prix,
            prix_proprietaire,
            nbre_sejour,
            status,
            autres_equipements,
            frais_service,
            disponibilite_status,
            proprietaire_id,

            residence:residences!appartements_residence_id_fkey (
              id,
              nom,
              ville,
              adresse,
              status,
              localisation
            )
          ),

          locataire:users!reservations_locataire_id_fkey (
            id,
            nom,
            prenom,
            email,
            telephone,
            adresse,
            urgencephone
          ),

          proprietaire:users!reservations_proprietaire_id_fkey (
            id,
            nom,
            prenom,
            email,
            telephone,
            adresse,
            urgencephone
          )
        ''')
          .order(
        'created_at',
        ascending: false,
      );

      final List<Map<String, dynamic>> loadedReservations =
      List<Map<String, dynamic>>.from(response);

      debugPrint(
        '${loadedReservations.length} réservations récupérées',
      );


      // VÉRIFICATION DES DONNÉES
      for (final reservation in loadedReservations) {
        final appartement =
        reservation['appartement'] as Map<String, dynamic>?;

        final locataire =
        reservation['locataire'] as Map<String, dynamic>?;

        final proprietaire =
        reservation['proprietaire'] as Map<String, dynamic>?;

        final reservationId =
        reservation['id']?.toString();

        final residence =
        appartement?['residence'] as Map<String, dynamic>?;

        debugPrint(
          'Réservation : $reservationId',
        );

        debugPrint(
          'Appartement : '
              '${appartement?['titre'] ?? 'Introuvable'}',
        );

        debugPrint(
          'Résidence : '
              '${residence?['nom'] ?? 'Aucune'}',
        );

        debugPrint(
          'Ville : '
              '${residence?['ville'] ?? 'Non renseignée'}',
        );

        debugPrint(
          'Locataire : '
              '${locataire?['prenom'] ?? ''} '
              '${locataire?['nom'] ?? ''}',
        );

        debugPrint(
          'Propriétaire : '
              '${proprietaire?['prenom'] ?? ''} '
              '${proprietaire?['nom'] ?? ''}',
        );
      }

      if (!mounted) return;

      setState(() {
        reservations = loadedReservations;

        _applyFilterWithoutSetState(
          selectedFilter,
        );
      });

      debugPrint(
        'Réservations chargées avec succès',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Erreur chargement réservations : $e',
      );

      debugPrint(
        '$stackTrace',
      );

      if (mounted) {
        setState(() {
          reservations = [];
          filteredReservations = [];
        });

        _safeShowSnackBar(
          'Impossible de charger les réservations',
          Colors.red,
          Icons.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isFetching = false;
        });
      }
    }
  }

  // FILTRES
  void _applyFilterWithoutSetState(String filter) {
    selectedFilter = filter;

    if (filter == 'Toutes') {
      filteredReservations =
      List<Map<String, dynamic>>.from(reservations);
      return;
    }

    final Map<String, String> statusMap = {
      'En attente': 'en_attente',
      'Confirmé': 'confirmee',
      'Annulé': 'annulee',
      'Terminé': 'terminee',
    };

    final String? status = statusMap[filter];

    if (status == null) {
      filteredReservations =
      List<Map<String, dynamic>>.from(reservations);
      return;
    }

    filteredReservations = reservations.where((reservation) {
      return reservation['statut']?.toString() == status;
    }).toList();
  }

  void _applyFilter(String filter) {
    if (!mounted) return;

    setState(() {
      _applyFilterWithoutSetState(filter);
    });
  }

  // STATISTIQUES
  Map<String, int> _getStats() {
    return {
      'Toutes': reservations.length,

      'En attente': reservations.where(
            (reservation) =>
        reservation['statut']?.toString() == 'en_attente',
      ).length,

      'Confirmé': reservations.where(
            (reservation) =>
        reservation['statut']?.toString() == 'confirmee',
      ).length,

      'Annulé': reservations.where(
            (reservation) =>
        reservation['statut']?.toString() == 'annulee',
      ).length,

      'Terminé': reservations.where(
            (reservation) =>
        reservation['statut']?.toString() == 'terminee',
      ).length,
    };
  }

  // SNACKBAR
  void _safeShowSnackBar(
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
          backgroundColor: color.withValues(alpha: 0.9),
          margin: EdgeInsets.all(16.w),
          content: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }


  // FORMATAGE PRIX
  String _formatPrix(dynamic prix) {
    if (prix == null) return '0 XOF';

    double? number;

    if (prix is num) {
      number = prix.toDouble();
    } else {
      number = double.tryParse(
        prix.toString().replaceAll(',', '.'),
      );
    }

    if (number == null) return '0 XOF';

    return NumberFormat
        .decimalPattern('fr_FR')
        .format(number) +
        ' XOF';
  }


  // FORMATAGE DATE
  String _formatDate(dynamic date) {
    if (date == null) return '';

    try {
      if (date is DateTime) {
        return DateFormat('dd/MM/yyyy').format(date);
      }

      return DateFormat('dd/MM/yyyy').format(
        DateTime.parse(date.toString()),
      );
    } catch (_) {
      return date.toString();
    }
  }

  // ============================================================
  // NOMBRE DE NUITS
  // ============================================================

  int _calculateNights(
      DateTime start,
      DateTime end,
      ) {
    return end.difference(start).inDays;
  }

  // ============================================================
  // MODIFICATION STATUT
  // ============================================================

  Future<void> _confirmReservation(String reservationId) async {
    try {
      final result = await _dbService.confirmerReservation(
        reservationId,
      );

      await _fetchReservations();

      if (!mounted) return;

      final montant = result['montant'];

      _safeShowSnackBar(
        'Réservation confirmée. '
            'Paiement de ${_formatPrix(montant)} en attente.',
        const Color(0xFFF59E0B),
        Icons.payment,
      );
    } catch (e) {
      debugPrint(
        '❌ Erreur confirmation réservation : $e',
      );

      if (!mounted) return;

      _safeShowSnackBar(
        e.toString().replaceFirst('Exception: ', ''),
        Colors.red,
        Icons.error,
      );
    }
  }

  Future<void> _refuseReservation(
      String reservationId,
      ) async {
    try {
      final result = await _dbService.refuserReservation(
        reservationId,
      );

      await _fetchReservations();

      if (!mounted) return;

      _safeShowSnackBar(
        'Réservation refusée.',
        const Color(0xFFEF4444),
        Icons.cancel,
      );

      debugPrint(
        '✅ Refus effectué : ${result['reservation_id']}',
      );
    } catch (e) {
      if (!mounted) return;

      _safeShowSnackBar(
        'Impossible de refuser la réservation : $e',
        const Color(0xFFEF4444),
        Icons.error_outline,
      );
    }
  }


  Future<void> _cancelReservation(
      String reservationId,
      ) async {
    try {
      await _dbService.cancelReservation(
        reservationId,
      );

      await _fetchReservations();

      if (!mounted) return;

      _safeShowSnackBar(
        'Réservation annulée.',
        const Color(0xFFF59E0B),
        Icons.event_busy,
      );
    } catch (e) {
      if (!mounted) return;

      _safeShowSnackBar(
        'Impossible d’annuler la réservation : $e',
        const Color(0xFFEF4444),
        Icons.error_outline,
      );
    }
  }

  // ============================================================
  // RECHERCHE
  // ============================================================

  void _showSearchDialog() {
    ReservationSearchDialog.show(
      context,
      reservations,
          (query) {
        if (!mounted) return;

        final search = query.trim().toLowerCase();

        setState(() {
          if (search.isEmpty) {
            _applyFilterWithoutSetState(
              selectedFilter,
            );
            return;
          }

          filteredReservations = reservations.where((reservation) {
            final appartement =
            reservation['appartement']
            as Map<String, dynamic>?;

            final locataire =
            reservation['locataire']
            as Map<String, dynamic>?;

            // IMPORTANT :
            // Le propriétaire est directement dans reservation
            final proprietaire =
            reservation['proprietaire']
            as Map<String, dynamic>?;

            final titre =
                appartement?['titre']
                    ?.toString()
                    .toLowerCase() ??
                    '';

            final residence =
            appartement?['residence']
            as Map<String, dynamic>?;

            final ville =
                residence?['ville']
                    ?.toString()
                    .toLowerCase() ??
                    '';

            final adresse =
                residence?['adresse']
                    ?.toString()
                    .toLowerCase() ??
                    '';

            final nomLocataire =
                locataire?['nom']
                    ?.toString()
                    .toLowerCase() ??
                    '';

            final prenomLocataire =
                locataire?['prenom']
                    ?.toString()
                    .toLowerCase() ??
                    '';

            final nomProprietaire =
                proprietaire?['nom']
                    ?.toString()
                    .toLowerCase() ??
                    '';

            final prenomProprietaire =
                proprietaire?['prenom']
                    ?.toString()
                    .toLowerCase() ??
                    '';

            final emailProprietaire =
                proprietaire?['email']
                    ?.toString()
                    .toLowerCase() ??
                    '';

            final telephoneProprietaire =
                proprietaire?['telephone']
                    ?.toString()
                    .toLowerCase() ??
                    '';

            return titre.contains(search) ||
                ville.contains(search) ||
                adresse.contains(search) ||
                nomLocataire.contains(search) ||
                prenomLocataire.contains(search) ||
                nomProprietaire.contains(search) ||
                prenomProprietaire.contains(search) ||
                emailProprietaire.contains(search) ||
                telephoneProprietaire.contains(search);
          }).toList();
        });
      },
          () => _applyFilter(selectedFilter),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Réservations',
      actions: [
        IconButton(
          icon: const Icon(
            Icons.refresh,
            color: Color(0xFFFFC107),
            size: 20,
          ),
          onPressed: isFetching
              ? null
              : _fetchReservations,
        ),
        IconButton(
          icon: const Icon(
            Icons.search,
            color: Colors.white54,
            size: 20,
          ),
          onPressed: _showSearchDialog,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReservationFilterChips(
            filterOptions: filterOptions,
            selectedFilter: selectedFilter,
            stats: _getStats(),
            onFilterSelected: _applyFilter,
          ),

          SizedBox(height: 24.h),

          _buildMainContent(),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENU PRINCIPAL
  // ============================================================

  Widget _buildMainContent() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111622),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.05,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${filteredReservations.length} réservations trouvées',
            style: GoogleFonts.manrope(
              color: Colors.white60,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 20.h),

          if (isFetching)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFC107),
              ),
            )
          else if (filteredReservations.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              itemCount: filteredReservations.length,
              separatorBuilder: (_, __) {
                return Divider(
                  color: Colors.white.withValues(
                    alpha: 0.05,
                  ),
                  height: 1,
                );
              },
              itemBuilder: (context, index) {
                final reservation =
                filteredReservations[index];

                // APPARTEMENT
                final appartement =
                reservation['appartement']
                as Map<String, dynamic>?;

                // LOCATAIRE
                final locataire =
                reservation['locataire']
                as Map<String, dynamic>?;

                // PROPRIÉTAIRE
                final proprietaire =
                reservation['proprietaire']
                as Map<String, dynamic>?;

                // STATUT
                final status =
                    reservation['statut']?.toString() ??
                        'en_attente';

                // DATES
                DateTime? dateDebut;
                DateTime? dateFin;

                try {
                  if (reservation['date_debut'] != null) {
                    dateDebut = DateTime.parse(
                      reservation['date_debut'].toString(),
                    );
                  }

                  if (reservation['date_fin'] != null) {
                    dateFin = DateTime.parse(
                      reservation['date_fin'].toString(),
                    );
                  }
                } catch (_) {}

                final nombreNuits =
                dateDebut != null && dateFin != null
                    ? _calculateNights(
                  dateDebut,
                  dateFin,
                )
                    : 0;

                // NOM PROPRIÉTAIRE
                final nomProprietaire =
                proprietaire != null
                    ? '${proprietaire['prenom'] ?? ''} '
                    '${proprietaire['nom'] ?? ''}'
                    .trim()
                    : 'Propriétaire inconnu';

                // NOM LOCATAIRE
                final nomLocataire =
                locataire != null
                    ? '${locataire['prenom'] ?? ''} '
                    '${locataire['nom'] ?? ''}'
                    .trim()
                    : 'Locataire inconnu';

                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.center,
                    children: [

                      // INFORMATIONS RÉSERVATION
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              appartement?['titre'] ??
                                  'Sans titre',
                              style: GoogleFonts.manrope(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 20.sp,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                            ),

                            SizedBox(height: 5.h),

                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 24.sp,
                                  color: Colors.white54,
                                ),
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nomLocataire,
                                        style: GoogleFonts.manrope(
                                          color: Colors.white54,
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      SizedBox(height: 2.h),

                                      Container(
                                        height: 2.h,
                                        width: 100,
                                        color: Colors.white70,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 5.h),

                            Text(
                              dateDebut != null &&
                                  dateFin != null
                                  ? '${_formatDate(dateDebut)} → '
                                  '${_formatDate(dateFin)} • '
                                  '$nombreNuits nuits'
                                  : 'Dates indisponibles',
                              style: GoogleFonts.manrope(
                                color: Colors.white70,
                                fontSize: 18.sp,
                              ),
                            ),

                            SizedBox(height: 3.h),

                            Text(
                              '${_formatPrix(reservation['prix_total'])} • '
                                  '${(reservation['adulte'] ?? 0) + (reservation['enfant'] ?? 0)} personnes',
                              style: GoogleFonts.manrope(
                                color: Colors.white38,
                                fontSize: 18.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // SÉPARATEUR
                      Container(
                        width: 3.w,
                        height: 150.h,
                        color: Colors.white.withValues(
                          alpha: 0.1,
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: 20.w,
                        ),
                      ),

                      // PROPRIÉTAIRE
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PROPRIÉTAIRE',
                              style: GoogleFonts.manrope(
                                color: Colors.white38,
                                fontSize: 14.sp,
                                fontWeight:
                                FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),

                            SizedBox(height: 10.h),

                            Row(
                              children: [
                                Container(
                                  width: 30.w,
                                  height: 30.w,
                                  decoration:
                                  BoxDecoration(
                                    color:
                                    const Color(
                                      0xFFFFC107,
                                    ).withValues(
                                      alpha: 0.12,
                                    ),
                                    shape:
                                    BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color:
                                    const Color(
                                      0xFFFFC107,
                                    ),
                                    size: 16.sp,
                                  ),
                                ),

                                SizedBox(width: 8.w),

                                Expanded(
                                  child: Text(
                                    nomProprietaire,
                                    style: GoogleFonts.manrope(
                                      color:
                                      proprietaire !=
                                          null
                                          ? Colors
                                          .white70
                                          : Colors
                                          .white38,
                                      fontSize: 20.sp,
                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow
                                        .ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            // TÉLÉPHONE
                            if (proprietaire?[
                            'telephone'] !=
                                null) ...[
                              SizedBox(height: 5.h),

                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 18.sp,
                                    color:
                                    Colors.white38,
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      proprietaire![
                                      'telephone']
                                          .toString(),
                                      style: GoogleFonts.manrope(
                                        color:
                                        Colors.white38,
                                        fontSize: 16.sp,
                                      ),
                                      maxLines: 1,
                                      overflow:
                                      TextOverflow
                                          .ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // EMAIL
                            if (proprietaire?['email'] !=
                                null) ...[
                              SizedBox(height: 3.h),

                              Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 13.sp,
                                    color:
                                    Colors.white38,
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      proprietaire![
                                      'email']
                                          .toString(),
                                      style: GoogleFonts.manrope(
                                        color:
                                        Colors.white38,
                                        fontSize: 16.sp,
                                      ),
                                      maxLines: 1,
                                      overflow:
                                      TextOverflow
                                          .ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // STATUT + ACTIONS
                      SizedBox(width: 16.w),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding:
                            EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 5.h,
                            ),
                            decoration:
                            BoxDecoration(
                              color: ReservationHelpers
                                  .getStatusColor(
                                  status)
                                  .withValues(
                                alpha: 0.15,
                              ),
                              borderRadius:
                              BorderRadius.circular(
                                6.r,
                              ),
                            ),
                            child: Text(
                              ReservationHelpers
                                  .getStatusText(status),
                              style: GoogleFonts.manrope(
                                color:
                                ReservationHelpers
                                    .getStatusColor(
                                    status),
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),

                          SizedBox(width: 8.w),

                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white60,
                            ),
                            color: const Color(0xFF111622),

                            onSelected: (value) async {
                              final reservationId =
                              reservation['id'].toString();

                              if (value == 'detail') {
                                ReservationDetailsDialog.show(
                                  context,
                                  reservation,

                                  // =====================================================
                                  // CONFIRMER
                                  // =====================================================
                                      () async {
                                    await _confirmReservation(
                                      reservationId,
                                    );
                                  },

                                  // =====================================================
                                  // REFUSER
                                  // =====================================================
                                      () async {
                                    await _refuseReservation(
                                      reservationId,
                                    );
                                  },

                                  // =====================================================
                                  // ANNULER
                                  // =====================================================
                                      () async {
                                    await _cancelReservation(
                                      reservationId,
                                    );
                                  },
                                );
                              }

                              // =======================================================
                              // CONFIRMER
                              // =======================================================
                              if (value == 'confirmer') {
                                await _confirmReservation(
                                  reservationId,
                                );
                              }

                              // =======================================================
                              // REFUSER
                              // =======================================================
                              if (value == 'refuser') {
                                await _refuseReservation(
                                  reservationId,
                                );
                              }

                              // =======================================================
                              // ANNULER
                              // =======================================================
                              if (value == 'annuler') {
                                await _cancelReservation(
                                  reservationId,
                                );
                              }
                            },

                            itemBuilder: (_) => [
                              // =======================================================
                              // DÉTAILS
                              // =======================================================
                              PopupMenuItem<String>(
                                value: 'detail',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.white,
                                      size: 20.sp,
                                    ),

                                    SizedBox(
                                      width: 12.w,
                                    ),

                                    Text(
                                      'Détails',
                                      style: GoogleFonts.manrope(
                                        color: Colors.white,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // =======================================================
                              // EN ATTENTE
                              // =======================================================
                              if (status == 'en_attente') ...[
                                // -------------------------------------------------------
                                // CONFIRMER
                                // -------------------------------------------------------
                                PopupMenuItem<String>(
                                  value: 'confirmer',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.green,
                                        size: 20.sp,
                                      ),

                                      SizedBox(
                                        width: 12.w,
                                      ),

                                      Text(
                                        'Confirmer',
                                        style: GoogleFonts.manrope(
                                          color: Colors.green,
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // -------------------------------------------------------
                                // REFUSER
                                // -------------------------------------------------------
                                PopupMenuItem<String>(
                                  value: 'refuser',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.red,
                                        size: 20.sp,
                                      ),

                                      SizedBox(
                                        width: 12.w,
                                      ),

                                      Text(
                                        'Refuser',
                                        style: GoogleFonts.manrope(
                                          color: Colors.red,
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // =======================================================
                              // CONFIRMÉE
                              // =======================================================
                              if (status == 'confirmee')
                                PopupMenuItem<String>(
                                  value: 'annuler',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.dangerous_outlined,
                                        color: Colors.red,
                                        size: 20.sp,
                                      ),

                                      SizedBox(
                                        width: 12.w,
                                      ),

                                      Text(
                                        'Annuler',
                                        style: GoogleFonts.manrope(
                                          color: Colors.red,
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // EMPTY STATE
  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 40.h,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64.w,
              color: Colors.white24,
            ),

            SizedBox(height: 16.h),

            Text(
              'Aucune réservation disponible',
              style: GoogleFonts.manrope(
                color: Colors.white38,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
