import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service/backend_service.dart';

import 'package:owner_app/core/theme/app_theme.dart';
import '../core/navigation/main_wrapper.dart';

// ============================================================
// MODÈLES
// ============================================================

class Transaction {
  final String id;
  final String name;
  final String apt;
  final String date;
  final double amount;
  final String type;
  final String statut;

  const Transaction({
    required this.id,
    required this.name,
    required this.apt,
    required this.date,
    required this.amount,
    required this.type,
    required this.statut,
  });
}

class AptRevenue {
  final String id;
  final String name;
  final double revenue;
  final double pct;
  final Color color;

  const AptRevenue({
    required this.id,
    required this.name,
    required this.revenue,
    required this.pct,
    required this.color,
  });
}

// ============================================================
// SKELETON CARD
// ============================================================

class _SkeletonRevenueCard extends StatefulWidget {
  const _SkeletonRevenueCard();

  @override
  State<_SkeletonRevenueCard> createState() => _SkeletonRevenueCardState();
}

class _SkeletonRevenueCardState extends State<_SkeletonRevenueCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller.drive(
        CurveTween(curve: Curves.easeInOut),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre skeleton
            Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FA),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            // Graphique skeleton (barres)
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  8,
                      (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        height: 20 + (index % 5) * 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FA),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Legend skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                3,
                    (index) => Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FA),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 40,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FA),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SKELETON KPI
// ============================================================

class _SkeletonKPI extends StatelessWidget {
  const _SkeletonKPI();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 17,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FA),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 60,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FA),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SKELETON APARTMENT ITEM
// ============================================================

class _SkeletonApartmentItem extends StatelessWidget {
  const _SkeletonApartmentItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FA),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 13,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FA),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 13,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FA),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FA),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 3),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 40,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FA),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PAGE REVENUS
// ============================================================

class RevenusPage extends StatefulWidget {
  final NavigateCallback onNavigate;

  const RevenusPage({
    super.key,
    required this.onNavigate,
  });

  @override
  State<RevenusPage> createState() => _RevenusPageState();
}

class _RevenusPageState extends State<RevenusPage> {
  final BackendService _backend = BackendService();

  String _period = 'month';
  String _tab = 'chart';

  bool _isLoading = true;
  String? _error;

  // ============================================================
  // DONNÉES
  // ============================================================

  double _revenuMois = 0;
  double _revenuAnnee = 0;
  double _evolutionRevenus = 0;

  int _nuitsLoueessMois = 0;
  int _nuitsLoueesAnnee = 0;

  double _tauxOccupationMois = 0;
  double _prixMoyenNuit = 0;

  int _reservationsMois = 0;
  int _reservationsAnnee = 0;

  List<double> _monthlyData = List.filled(12, 0);
  List<AptRevenue> _byApt = [];
  List<Transaction> _transactions = [];

  final int _currentMonthIndex = DateTime.now().month - 1;

  final List<String> months = const [
    'Jan',
    'Fév',
    'Mar',
    'Avr',
    'Mai',
    'Jun',
    'Jul',
    'Aoû',
    'Sep',
    'Oct',
    'Nov',
    'Déc',
  ];

  final List<Color> _chartColors = const [
    Color(0xFF1B3A6B),
    Color(0xFFC9913A),
    Color(0xFF10B981),
    Color(0xFF6366F1),
    Color(0xFFEC4899),
    Color(0xFF0EA5E9),
    Color(0xFFF97316),
    Color(0xFF14B8A6),
  ];

  @override
  void initState() {
    super.initState();
    _loadRevenueData();
  }

  // ============================================================
  // CHARGEMENT GLOBAL
  // ============================================================

  Future<void> _loadRevenueData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = _backend.currentUser;

      if (user == null) {
        throw Exception('Utilisateur non connecté.');
      }

      final now = DateTime.now();

      final currentMonthStart = DateTime(
        now.year,
        now.month,
        1,
      );

      final nextMonthStart = DateTime(
        now.year,
        now.month + 1,
        1,
      );

      final previousMonthStart = DateTime(
        now.year,
        now.month - 1,
        1,
      );

      final yearStart = DateTime(
        now.year,
        1,
        1,
      );

      final nextYearStart = DateTime(
        now.year + 1,
        1,
        1,
      );

      // ----------------------------------------------------------
      // RÉCUPÉRATION DES APPARTEMENTS
      // ----------------------------------------------------------

      final apartmentsResponse = await _backend.supabase
          .from('appartements')
          .select('''
            id,
            titre,
            prix,
            prix_proprietaire,
            status
          ''')
          .eq('proprietaire_id', user.id);

      final apartments =
      List<Map<String, dynamic>>.from(apartmentsResponse);

      // ----------------------------------------------------------
      // RÉCUPÉRATION DES RÉSERVATIONS
      //
      // IMPORTANT :
      // prix_proprietaire = TOTAL DE LA RÉSERVATION
      // ----------------------------------------------------------

      final reservationsResponse = await _backend.supabase
          .from('reservations')
          .select('''
            id,
            appartement_id,
            proprietaire_id,
            date_debut,
            date_fin,
            prix_total,
            prix_proprietaire,
            frais_service,
            reduction,
            statut,
            created_at
          ''')
          .eq('proprietaire_id', user.id)
          .order('created_at', ascending: false);

      final reservations =
      List<Map<String, dynamic>>.from(reservationsResponse);

      // ----------------------------------------------------------
      // CALCULS
      // ----------------------------------------------------------

      final monthlyRevenue = List<double>.filled(12, 0);

      double revenuMois = 0;
      double revenuMoisPrecedent = 0;
      double revenuAnnee = 0;

      int nuitsMois = 0;
      int nuitsAnnee = 0;

      int reservationsMois = 0;
      int reservationsAnnee = 0;

      final Map<String, double> revenueByApartment = {};

      // ----------------------------------------------------------
      // PARCOURIR LES RÉSERVATIONS
      // ----------------------------------------------------------

      for (final reservation in reservations) {
        final statut = _normalizeStatus(
          reservation['statut'],
        );

        if (!_isRevenueStatus(statut)) {
          continue;
        }

        final debut = _parseDate(
          reservation['date_debut'],
        );

        final fin = _parseDate(
          reservation['date_fin'],
        );

        if (debut == null || fin == null) {
          continue;
        }

        if (!fin.isAfter(debut)) {
          continue;
        }

        final prixTotalProprietaire = _toDouble(
          reservation['prix_proprietaire'],
        );

        if (prixTotalProprietaire <= 0) {
          continue;
        }

        // --------------------------------------------------------
        // REVENUS DU MOIS

        final revenuMoisReservation = _calculatePeriodRevenue(
          reservationStart: debut,
          reservationEnd: fin,
          reservationTotal: prixTotalProprietaire,
          periodStart: currentMonthStart,
          periodEnd: nextMonthStart,
        );

        revenuMois += revenuMoisReservation;

        // --------------------------------------------------------
        // MOIS PRÉCÉDENT
        // --------------------------------------------------------

        final revenuPrecedentReservation = _calculatePeriodRevenue(
          reservationStart: debut,
          reservationEnd: fin,
          reservationTotal: prixTotalProprietaire,
          periodStart: previousMonthStart,
          periodEnd: currentMonthStart,
        );

        revenuMoisPrecedent += revenuPrecedentReservation;

        // --------------------------------------------------------
        // ANNÉE
        // --------------------------------------------------------

        final revenuAnneeReservation = _calculatePeriodRevenue(
          reservationStart: debut,
          reservationEnd: fin,
          reservationTotal: prixTotalProprietaire,
          periodStart: yearStart,
          periodEnd: nextYearStart,
        );

        revenuAnnee += revenuAnneeReservation;

        // --------------------------------------------------------
        // GRAPHIQUE MENSUEL
        // --------------------------------------------------------

        for (int month = 1; month <= 12; month++) {
          final start = DateTime(
            now.year,
            month,
            1,
          );

          final end = DateTime(
            now.year,
            month + 1,
            1,
          );

          final revenueForMonth = _calculatePeriodRevenue(
            reservationStart: debut,
            reservationEnd: fin,
            reservationTotal: prixTotalProprietaire,
            periodStart: start,
            periodEnd: end,
          );

          monthlyRevenue[month - 1] += revenueForMonth;
        }

        // --------------------------------------------------------
        // NUITS DU MOIS
        // --------------------------------------------------------

        nuitsMois += _calculateNightsInPeriod(
          reservationStart: debut,
          reservationEnd: fin,
          periodStart: currentMonthStart,
          periodEnd: nextMonthStart,
        );

        // --------------------------------------------------------
        // NUITS ANNÉE
        // --------------------------------------------------------

        nuitsAnnee += _calculateNightsInPeriod(
          reservationStart: debut,
          reservationEnd: fin,
          periodStart: yearStart,
          periodEnd: nextYearStart,
        );

        // --------------------------------------------------------
        // RÉSERVATIONS DU MOIS
        // --------------------------------------------------------

        if (_overlapsPeriod(
          debut,
          fin,
          currentMonthStart,
          nextMonthStart,
        )) {
          reservationsMois++;
        }

        // --------------------------------------------------------
        // RÉSERVATIONS ANNÉE
        // --------------------------------------------------------

        if (_overlapsPeriod(
          debut,
          fin,
          yearStart,
          nextYearStart,
        )) {
          reservationsAnnee++;
        }

        // --------------------------------------------------------
        // REVENUS PAR APPARTEMENT

        final appartementId =
        reservation['appartement_id']?.toString();

        if (appartementId != null) {
          final revenuAppartement =
          _calculatePeriodRevenue(
            reservationStart: debut,
            reservationEnd: fin,
            reservationTotal: prixTotalProprietaire,
            periodStart: _period == 'month'
                ? currentMonthStart
                : yearStart,
            periodEnd: _period == 'month'
                ? nextMonthStart
                : nextYearStart,
          );

          revenueByApartment[appartementId] =
              (revenueByApartment[appartementId] ?? 0) +
                  revenuAppartement;
        }
      }

      // ==========================================================
      // ÉVOLUTION REVENUS
      // ==========================================================

      double evolution = 0;

      if (revenuMoisPrecedent > 0) {
        evolution =
            ((revenuMois - revenuMoisPrecedent) /
                revenuMoisPrecedent) *
                100;
      } else if (revenuMois > 0) {
        evolution = 100;
      }

      // ==========================================================
      // TAUX D'OCCUPATION
      // ==========================================================

      final joursDansMois =
          nextMonthStart.difference(currentMonthStart).inDays;

      final nuitsDisponibles =
          apartments.length * joursDansMois;

      double tauxOccupation = 0;

      if (nuitsDisponibles > 0) {
        tauxOccupation =
            (nuitsMois / nuitsDisponibles) * 100;
      }

      tauxOccupation =
          tauxOccupation.clamp(0.0, 100.0);

      // ==========================================================
      // PRIX MOYEN / NUIT
      // ==========================================================

      double prixMoyenNuit = 0;

      if (nuitsMois > 0) {
        prixMoyenNuit =
            revenuMois / nuitsMois;
      }

      // ==========================================================
      // REVENUS PAR APPARTEMENT
      // ==========================================================

      final totalRevenueForApt =
      revenueByApartment.values.fold<double>(
        0,
            (sum, value) => sum + value,
      );

      final List<AptRevenue> byApt = [];

      for (int i = 0; i < apartments.length; i++) {
        final apartment = apartments[i];

        final id = apartment['id']?.toString();

        if (id == null) {
          continue;
        }

        final revenue = revenueByApartment[id] ?? 0;

        if (revenue <= 0) {
          continue;
        }

        final double percentage =
        totalRevenueForApt > 0
            ? (revenue / totalRevenueForApt) * 100.0
            : 0.0;

        byApt.add(
          AptRevenue(
            id: id,
            name: apartment['titre']?.toString() ?? 'Appartement',
            revenue: revenue,
            pct: percentage,
            color: _chartColors[
            byApt.length % _chartColors.length
            ],
          ),
        );
      }

      byApt.sort(
            (a, b) => b.revenue.compareTo(a.revenue),
      );

      // ==========================================================
      // TRANSACTIONS
      // ==========================================================

      final List<Transaction> transactions = [];

      for (final reservation in reservations) {
        final statut = _normalizeStatus(
          reservation['statut'],
        );

        if (!_isRevenueStatus(statut)) {
          continue;
        }

        final debut = _parseDate(
          reservation['date_debut'],
        );

        final fin = _parseDate(
          reservation['date_fin'],
        );

        if (debut == null || fin == null) {
          continue;
        }

        final total = _toDouble(
          reservation['prix_proprietaire'],
        );

        if (total <= 0) {
          continue;
        }

        final apartmentId =
        reservation['appartement_id']?.toString();

        final apartment = apartments.cast<
            Map<String, dynamic>?>().firstWhere(
              (apt) =>
          apt?['id']?.toString() == apartmentId,
          orElse: () => null,
        );

        final apartmentName =
            apartment?['titre']?.toString() ??
                'Appartement';

        transactions.add(
          Transaction(
            id: reservation['id']?.toString() ??
                UniqueKey().toString(),
            name: 'Réservation',
            apt: apartmentName,
            date:
            '${_formatDate(debut)} → ${_formatDate(fin)}',
            amount: total,
            type: 'credit',
            statut: statut,
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        _revenuMois = revenuMois;
        _revenuAnnee = revenuAnnee;
        _evolutionRevenus = evolution;

        _nuitsLoueessMois = nuitsMois;
        _nuitsLoueesAnnee = nuitsAnnee;

        _tauxOccupationMois = tauxOccupation;
        _prixMoyenNuit = prixMoyenNuit;

        _reservationsMois = reservationsMois;
        _reservationsAnnee = reservationsAnnee;

        _monthlyData = monthlyRevenue;
        _byApt = byApt;
        _transactions = transactions;

        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint(
        '❌ RevenusPage._loadRevenueData: $e',
      );

      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'Impossible de charger les revenus.';
      });
    }
  }

  // ============================================================
  // STATUT REVENUS
  // ============================================================

  bool _isRevenueStatus(String status) {
    return status == 'confirmee' ||
        status == 'terminee';
  }

  String _normalizeStatus(dynamic value) {
    return value
        ?.toString()
        .trim()
        .toLowerCase()
        .replaceAll('é', 'e') ??
        '';
  }

  // ============================================================
  // CALCUL REVENU PÉRIODE
  // ============================================================
  //
  // IMPORTANT :
  //
  // reservationTotal = montant TOTAL de la réservation.
  //
  // Si la réservation est entièrement dans la période :
  //
  // 300 000 → 300 000
  //
  // Si elle traverse deux périodes :
  // répartition proportionnelle par nuit.
  //
  // ============================================================

  double _calculatePeriodRevenue({
    required DateTime reservationStart,
    required DateTime reservationEnd,
    required double reservationTotal,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    if (!reservationEnd.isAfter(reservationStart)) {
      return 0;
    }

    if (reservationTotal <= 0) {
      return 0;
    }

    final overlapStart = reservationStart.isAfter(periodStart)
        ? reservationStart
        : periodStart;

    final overlapEnd = reservationEnd.isBefore(periodEnd)
        ? reservationEnd
        : periodEnd;

    if (!overlapStart.isBefore(overlapEnd)) {
      return 0;
    }

    final totalNights =
        reservationEnd.difference(reservationStart).inDays;

    if (totalNights <= 0) {
      return 0;
    }

    final overlapNights =
        overlapEnd.difference(overlapStart).inDays;

    // Réservation entièrement dans la période :
    // on garde exactement le montant total.
    if (overlapNights == totalNights) {
      return reservationTotal;
    }

    // Réservation traversant plusieurs périodes.
    return reservationTotal *
        overlapNights /
        totalNights;
  }

  // ============================================================
  // CALCUL NUITS
  // ============================================================

  int _calculateNightsInPeriod({
    required DateTime reservationStart,
    required DateTime reservationEnd,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    final overlapStart = reservationStart.isAfter(periodStart)
        ? reservationStart
        : periodStart;

    final overlapEnd = reservationEnd.isBefore(periodEnd)
        ? reservationEnd
        : periodEnd;

    if (!overlapStart.isBefore(overlapEnd)) {
      return 0;
    }

    return overlapEnd
        .difference(overlapStart)
        .inDays;
  }

  // ============================================================
  // CHEVAUCHEMENT
  // ============================================================

  bool _overlapsPeriod(
      DateTime start,
      DateTime end,
      DateTime periodStart,
      DateTime periodEnd,
      ) {
    return start.isBefore(periodEnd) &&
        end.isAfter(periodStart);
  }

  // ============================================================
  // PARSE DATE
  // ============================================================

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return DateTime(
        value.year,
        value.month,
        value.day,
      );
    }

    final parsed =
    DateTime.tryParse(value.toString());

    if (parsed == null) {
      return null;
    }

    return DateTime(
      parsed.year,
      parsed.month,
      parsed.day,
    );
  }

  // ============================================================
  // DOUBLE
  // ============================================================

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value
          .toString()
          .replaceAll(' ', '')
          .replaceAll(',', '.'),
    ) ??
        0;
  }

  // ============================================================
  // FORMAT FCFA
  // ============================================================

  String _formatMoney(
      double value, {
        bool showCurrency = true,
      }) {
    final number = value.round();

    final formatted = number
        .toString()
        .replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ' ',
    );

    return showCurrency
        ? '$formatted FCFA'
        : formatted;
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // NOM DU MOIS
  // ============================================================

  String _monthName(int month) {
    const names = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];

    return names[month - 1];
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildError();
    }

    final maxVal = _monthlyData
        .where((v) => v > 0)
        .fold<double>(
      0,
      math.max,
    );

    return RefreshIndicator(
      onRefresh: _loadRevenueData,
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        children: [
          _buildHeader(),
          _buildMiniKPIs(),
          _buildTabs(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_tab == 'chart')
                  _buildBarChart(
                    maxVal > 0 ? maxVal : 1,
                    _currentMonthIndex,
                  ),

                if (_tab == 'apts')
                  _buildAptsView(),

                if (_tab == 'transactions')
                  _buildTransactionsView(),

                const SizedBox(height: 14),

                _buildExportButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING STATE AVEC SKELETONS
  // ============================================================

  Widget _buildLoadingState() {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _buildSkeletonHeader(),
        _buildSkeletonKPIs(),
        _buildSkeletonTabs(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const _SkeletonRevenueCard(),
              const SizedBox(height: 16),
              const _SkeletonRevenueCard(),
              const SizedBox(height: 16),
              // Skeleton pour les appartements ou transactions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.06),
                      blurRadius: 12,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FA),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _SkeletonApartmentItem(),
                    const _SkeletonApartmentItem(),
                    const _SkeletonApartmentItem(),
                    const _SkeletonApartmentItem(),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Skeleton export button
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SKELETON HEADER
  // ============================================================

  Widget _buildSkeletonHeader() {
    return Container(
      color: AppColors.foreground,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSkeletonPeriodBtn(true),
                _buildSkeletonPeriodBtn(false),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 120,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 150,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 50,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 10,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SKELETON PERIOD BUTTON
  // ============================================================

  Widget _buildSkeletonPeriodBtn(bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: 60,
        height: 13,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.inputText.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  // ============================================================
  // SKELETON KPIS
  // ============================================================

  Widget _buildSkeletonKPIs() {
    return Transform.translate(
      offset: const Offset(0, -12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: const [
            _SkeletonKPI(),
            _SkeletonKPI(),
            _SkeletonKPI(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SKELETON TABS
  // ============================================================

  Widget _buildSkeletonTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: List.generate(
            3,
                (index) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: index == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 11,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? AppColors.inputText.withValues(alpha: 0.3)
                          : const Color(0xFFEEF2FA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadRevenueData,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    final isMonth = _period == 'month';

    final title = isMonth
        ? '${_monthName(DateTime.now().month)} ${DateTime.now().year}'
        : 'Total ${DateTime.now().year}';

    final revenue =
    isMonth ? _revenuMois : _revenuAnnee;

    final evolutionText = _evolutionRevenus >= 0
        ? '↑ +${_evolutionRevenus.toStringAsFixed(0)}%'
        : '↓ ${_evolutionRevenus.toStringAsFixed(0)}%';

    final evolutionColor =
    _evolutionRevenus >= 0
        ? AppColors.success
        : AppColors.danger;

    return Container(
      color: AppColors.foreground,
      padding: const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        28,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.3,
              ),
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                _buildPeriodBtn(
                  'month',
                  'Ce mois',
                ),
                _buildPeriodBtn(
                  'year',
                  'Cette année',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                      GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.white
                            .withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),

                    const SizedBox(height: 2),

                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment:
                      Alignment.centerLeft,
                      child: Text(
                        _formatMoney(
                          revenue,
                        ),
                        style:
                        GoogleFonts.nunito(
                          fontWeight:
                          FontWeight.w900,
                          fontSize: 36,
                          color:
                          Colors.white,
                          letterSpacing:
                          -1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    if (isMonth)
                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration:
                        BoxDecoration(
                          color:
                          evolutionColor
                              .withValues(
                            alpha: 0.18,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            20,
                          ),
                        ),
                        child: Text(
                          '$evolutionText vs mois précédent',
                          style:
                          GoogleFonts.nunito(
                            fontWeight:
                            FontWeight.w800,
                            fontSize: 11,
                            color:
                            evolutionColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Text(
                    'Réservations',
                    style:
                    GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.white
                          .withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    '${isMonth ? _reservationsMois : _reservationsAnnee}',
                    style:
                    GoogleFonts.nunito(
                      fontWeight:
                      FontWeight.w900,
                      fontSize: 24,
                      color:
                      AppColors.accent,
                    ),
                  ),

                  Text(
                    'confirmées',
                    style:
                    GoogleFonts.nunito(
                      fontSize: 10,
                      color: Colors.white
                          .withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERIOD BUTTON
  // ============================================================

  Widget _buildPeriodBtn(
      String key,
      String label,
      ) {
    final selected = _period == key;

    return GestureDetector(
      onTap: () {
        setState(() {
          _period = key;
        });
      },
      child: Container(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.transparent,
          borderRadius:
          BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontWeight:
            FontWeight.w700,
            fontSize: 13,
            color: selected
                ? AppColors.inputText
                : Colors.white
                .withValues(
              alpha: 0.7,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MINI KPIS
  // ============================================================

  Widget _buildMiniKPIs() {
    final isMonth = _period == 'month';

    final kpis = [
      {
        'label': 'Nuits louées',
        'value':
        '${isMonth ? _nuitsLoueessMois : _nuitsLoueesAnnee}',
      },
      {
        'label': 'Taux occupation',
        'value':
        '${_tauxOccupationMois.toStringAsFixed(0)}%',
      },
      {
        'label': 'Prix moy./nuit',
        'value':
        _formatMoney(
          _prixMoyenNuit,
        ),
      },
    ];

    return Transform.translate(
      offset: const Offset(0, -12),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          children: kpis.map((k) {
            return Expanded(
              child: Container(
                margin:
                const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                padding:
                const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration:
                BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(
                        0,
                        0,
                        0,
                        0.06,
                      ),
                      blurRadius: 10,
                      offset:
                      Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    FittedBox(
                      child: Text(
                        k['value']!,
                        style:
                        GoogleFonts.nunito(
                          fontWeight:
                          FontWeight.w900,
                          fontSize: 17,
                          color:
                          AppColors
                              .inputText,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      k['label']!,
                      textAlign:
                      TextAlign.center,
                      style:
                      GoogleFonts.nunito(
                        fontSize: 10,
                        color:
                        AppColors
                            .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _buildTabs() {
    final tabs = [
      {
        'key': 'chart',
        'label': '📊 Graphique',
      },
      {
        'key': 'apts',
        'label': '🏠 Par bien',
      },
      {
        'key': 'transactions',
        'label': '💳 Transactions',
      },
    ];

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Container(
        padding:
        const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color:
          const Color(0xFFEEF2FA),
          borderRadius:
          BorderRadius.circular(12),
        ),
        child: Row(
          children: tabs.map((tab) {
            final selected =
                _tab == tab['key'];

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _tab =
                    tab['key']!;
                  });
                },
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  decoration:
                  BoxDecoration(
                    color: selected
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                    boxShadow: selected
                        ? const [
                      BoxShadow(
                        color:
                        Color.fromRGBO(
                          0,
                          0,
                          0,
                          0.08,
                        ),
                        blurRadius:
                        4,
                        offset:
                        Offset(
                          0,
                          1,
                        ),
                      ),
                    ]
                        : [],
                  ),
                  child: Text(
                    tab['label']!,
                    textAlign:
                    TextAlign.center,
                    style:
                    GoogleFonts.nunito(
                      fontWeight:
                      FontWeight.w700,
                      fontSize: 11,
                      color: selected
                          ? AppColors
                          .inputText
                          : AppColors
                          .textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // GRAPHIQUE
  // ============================================================

  Widget _buildBarChart(
      double maxVal,
      int currentMonthIdx,
      ) {
    final year =
        DateTime.now().year;

    return Container(
      padding:
      const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color:
            Color.fromRGBO(
              0,
              0,
              0,
              0.06,
            ),
            blurRadius: 12,
            offset:
            Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'Revenus mensuels $year',
            style:
            GoogleFonts.nunito(
              fontWeight:
              FontWeight.w800,
              fontSize: 16,
              color:
              AppColors.inputText,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children:
              List.generate(
                months.length,
                    (i) {
                  final value =
                  _monthlyData[i];

                  final height =
                  value > 0
                      ? (value /
                      maxVal) *
                      100
                      : 6.0;

                  final isCurrent =
                      i ==
                          currentMonthIdx;

                  final isFuture =
                      i >
                          currentMonthIdx;

                  Color barColor =
                      AppColors
                          .foreground;

                  if (isFuture) {
                    barColor =
                        AppColors
                            .mutedForeground;
                  }

                  if (isCurrent) {
                    barColor =
                        AppColors.accent;
                  }

                  return Expanded(
                    child: Padding(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 2,
                      ),
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .end,
                        children: [
                          if (isCurrent &&
                              value > 0)
                            Container(
                              margin:
                              const EdgeInsets
                                  .only(
                                bottom: 2,
                              ),
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 3,
                                vertical: 2,
                              ),
                              decoration:
                              BoxDecoration(
                                color:
                                const Color(
                                  0xFFC9913A,
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  4,
                                ),
                              ),
                              child: Text(
                                _formatMoney(
                                  value,
                                  showCurrency:
                                  false,
                                ),
                                style:
                                GoogleFonts
                                    .nunito(
                                  fontWeight:
                                  FontWeight
                                      .w700,
                                  fontSize:
                                  7,
                                  color:
                                  Colors
                                      .white,
                                ),
                              ),
                            ),

                          AnimatedContainer(
                            duration:
                            const Duration(
                              milliseconds:
                              300,
                            ),
                            height: height,
                            width:
                            double.infinity,
                            decoration:
                            BoxDecoration(
                              color:
                              barColor,
                              borderRadius:
                              const BorderRadius
                                  .vertical(
                                top:
                                Radius.circular(
                                  6,
                                ),
                                bottom:
                                Radius.circular(
                                  4,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            months[i],
                            style:
                            GoogleFonts
                                .nunito(
                              fontSize:
                              9,
                              fontWeight:
                              isCurrent
                                  ? FontWeight
                                  .bold
                                  : FontWeight
                                  .normal,
                              color:
                              isCurrent
                                  ? const Color(
                                0xFFC9913A,
                              )
                                  : const Color(
                                0xFF8A94A6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding:
            const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
              const Color(0xFFF8FAFF),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceAround,
              children: [
                _buildLegendItem(
                  AppColors.foreground,
                  'Mois passés',
                ),
                _buildLegendItem(
                  AppColors.accent,
                  'Mois actuel',
                ),
                _buildLegendItem(
                  AppColors.mutedForeground,
                  'À venir',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LEGEND
  // ============================================================

  Widget _buildLegendItem(
      Color color,
      String label,
      ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration:
          BoxDecoration(
            color: color,
            borderRadius:
            BorderRadius.circular(
              3,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style:
          GoogleFonts.nunito(
            fontSize: 10,
            color: AppColors
                .textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAR BIEN
  // ============================================================

  Widget _buildAptsView() {
    final total = _byApt.fold<double>(
      0,
          (sum, apt) =>
      sum + apt.revenue,
    );

    if (_byApt.isEmpty) {
      return _buildEmptyCard(
        icon: Icons.home_work_outlined,
        title: 'Aucun revenu',
        subtitle:
        'Aucun appartement n’a encore généré de revenu sur cette période.',
      );
    }

    return Container(
      padding:
      const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color:
            Color.fromRGBO(
              0,
              0,
              0,
              0.06,
            ),
            blurRadius: 12,
            offset:
            Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'Revenus par bien',
            style:
            GoogleFonts.nunito(
              fontWeight:
              FontWeight.w800,
              fontSize: 16,
              color:
              AppColors.inputText,
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment:
                Alignment.center,
                children: [
                  CustomPaint(
                    size:
                    const Size(
                      150,
                      150,
                    ),
                    painter:
                    DonutChartPainter(
                      byApt: _byApt,
                    ),
                  ),
                  Column(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                    children: [
                      Text(
                        _formatMoney(
                          total,
                          showCurrency:
                          false,
                        ),
                        style:
                        GoogleFonts
                            .nunito(
                          fontWeight:
                          FontWeight
                              .w900,
                          fontSize:
                          17,
                          color:
                          AppColors
                              .inputText,
                        ),
                      ),
                      Text(
                        'FCFA',
                        style:
                        GoogleFonts
                            .nunito(
                          fontSize:
                          10,
                          color:
                          AppColors
                              .textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Column(
            children:
            _byApt.map((apt) {
              return Padding(
                padding:
                const EdgeInsets
                    .only(
                  bottom: 12,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width:
                                10,
                                height:
                                10,
                                decoration:
                                BoxDecoration(
                                  color:
                                  apt.color,
                                  borderRadius:
                                  BorderRadius.circular(
                                    3,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width:
                                8,
                              ),
                              Expanded(
                                child:
                                Text(
                                  apt.name,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style:
                                  GoogleFonts.nunito(
                                    fontWeight:
                                    FontWeight.w700,
                                    fontSize:
                                    13,
                                    color:
                                    AppColors.inputText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          _formatMoney(
                            apt.revenue,
                          ),
                          style:
                          GoogleFonts
                              .nunito(
                            fontWeight:
                            FontWeight
                                .w800,
                            fontSize:
                            13,
                            color:
                            AppColors
                                .inputText,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    ClipRRect(
                      borderRadius:
                      BorderRadius
                          .circular(
                        3,
                      ),
                      child:
                      LinearProgressIndicator(
                        value:
                        apt.pct /
                            100,
                        minHeight:
                        6,
                        backgroundColor:
                        const Color(
                          0xFFF1F5F9,
                        ),
                        valueColor:
                        AlwaysStoppedAnimation<
                            Color>(
                          apt.color,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Align(
                      alignment:
                      Alignment
                          .centerRight,
                      child: Text(
                        '${apt.pct.toStringAsFixed(1)} %',
                        style:
                        GoogleFonts
                            .nunito(
                          fontSize:
                          10,
                          color:
                          AppColors
                              .textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRANSACTIONS
  // ============================================================

  Widget _buildTransactionsView() {
    if (_transactions.isEmpty) {
      return _buildEmptyCard(
        icon: Icons.receipt_long_outlined,
        title: 'Aucune transaction',
        subtitle:
        'Aucune réservation générant un revenu n’a été trouvée.',
      );
    }

    final total =
    _transactions.fold<double>(
      0,
          (sum, transaction) =>
      sum + transaction.amount,
    );

    return Column(
      children: [
        ..._transactions.map(
              (transaction) {
            return _buildTransactionCard(
              transaction,
            );
          },
        ),

        const SizedBox(height: 4),

        Container(
          padding:
          const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
            const Color(0xFFEEF2FA),
            borderRadius:
            BorderRadius.circular(
              14,
            ),
          ),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
            children: [
              Text(
                'Total revenus',
                style:
                GoogleFonts.nunito(
                  fontWeight:
                  FontWeight.w800,
                  fontSize: 15,
                  color: AppColors
                      .inputText,
                ),
              ),
              Text(
                '+${_formatMoney(total)}',
                style:
                GoogleFonts.nunito(
                  fontWeight:
                  FontWeight.w900,
                  fontSize: 18,
                  color:
                  AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CARTE TRANSACTION
  // ============================================================

  Widget _buildTransactionCard(
      Transaction transaction,
      ) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
      const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          14,
        ),
        boxShadow: const [
          BoxShadow(
            color:
            Color.fromRGBO(
              0,
              0,
              0,
              0.05,
            ),
            blurRadius: 8,
            offset:
            Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
            BoxDecoration(
              color:
              const Color(
                0xFFECFDF5,
              ),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons
                    .arrow_downward_rounded,
                color:
                AppColors.success,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  transaction.name,
                  style:
                  GoogleFonts
                      .nunito(
                    fontWeight:
                    FontWeight
                        .w700,
                    fontSize:
                    14,
                    color: AppColors
                        .inputText,
                  ),
                  overflow:
                  TextOverflow
                      .ellipsis,
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  '${transaction.apt} · ${transaction.date}',
                  style:
                  GoogleFonts
                      .nunito(
                    fontSize:
                    11,
                    color: AppColors
                        .textSecondary,
                  ),
                  overflow:
                  TextOverflow
                      .ellipsis,
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  _formatStatus(
                    transaction.statut,
                  ),
                  style:
                  GoogleFonts
                      .nunito(
                    fontSize:
                    10,
                    fontWeight:
                    FontWeight
                        .w700,
                    color:
                    AppColors
                        .success,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Text(
            '+${_formatMoney(transaction.amount)}',
            textAlign:
            TextAlign.right,
            style:
            GoogleFonts.nunito(
              fontWeight:
              FontWeight.w900,
              fontSize: 14,
              color:
              AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUT AFFICHAGE
  // ============================================================

  String _formatStatus(
      String status,
      ) {
    switch (status) {
      case 'confirmee':
        return 'Réservation confirmée';

      case 'terminee':
        return 'Séjour terminé';

      default:
        return status;
    }
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 42,
            color:
            AppColors.textSecondary,
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            title,
            style:
            GoogleFonts.nunito(
              fontWeight:
              FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            subtitle,
            textAlign:
            TextAlign.center,
            style:
            GoogleFonts.nunito(
              fontSize: 12,
              color: AppColors
                  .textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXPORT
  // ============================================================

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'L’export PDF sera ajouté prochainement.',
              ),
            ),
          );
        },
        style:
        ElevatedButton.styleFrom(
          backgroundColor:
          Colors.white,
          elevation: 0,
          padding:
          const EdgeInsets
              .symmetric(
            vertical: 14,
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              14,
            ),
            side:
            const BorderSide(
              color:
              Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.picture_as_pdf_outlined,
              size: 18,
              color:
              AppColors.inputText,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              'Exporter le rapport PDF',
              style:
              GoogleFonts.nunito(
                fontWeight:
                FontWeight.w800,
                fontSize: 14,
                color:
                AppColors.inputText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DONUT CHART
// ============================================================

class DonutChartPainter
    extends CustomPainter {
  final List<AptRevenue> byApt;

  DonutChartPainter({
    required this.byApt,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    const strokeWidth = 14.0;

    final radius =
        (size.width -
            strokeWidth) /
            2;

    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    double startAngle =
        -math.pi / 2;

    final total =
    byApt.fold<double>(
      0,
          (sum, apt) =>
      sum + apt.revenue,
    );

    if (total <= 0) {
      final paint = Paint()
        ..color =
        const Color(0xFFE2E8F0)
        ..style =
            PaintingStyle.stroke
        ..strokeWidth =
            strokeWidth;

      canvas.drawCircle(
        center,
        radius,
        paint,
      );

      return;
    }

    for (final apt in byApt) {
      final sweepAngle =
          (apt.revenue / total) *
              2 *
              math.pi;

      final paint = Paint()
        ..color = apt.color
        ..style =
            PaintingStyle.stroke
        ..strokeWidth =
            strokeWidth
        ..strokeCap =
            StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(
      covariant DonutChartPainter oldDelegate,
      ) {
    return oldDelegate.byApt !=
        byApt;
  }
}