import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../footer/footer.dart';
import '../../../models/dashboard_data.dart';
import '../../../responsive.dart';

import '../../controllers/dashboard_controller.dart';
import '../../widgets/main_layout.dart';

import 'components/recent_bookings.dart';
import 'components/revenue_chart.dart';
import 'components/stats_card.dart';
import 'components/top_cities.dart';

/// DASHBOARD SCREEN
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  bool _isInitialized = false;

  // INIT
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        _initializeDashboard();
      },
    );
  }

  // INITIALISATION
  void _initializeDashboard() {
    if (!mounted || _isInitialized) {
      return;
    }

    _isInitialized = true;

    context
        .read<DashboardController>()
        .loadDashboardData();
  }


  String _formatMoney(num value) {
    final formatted = value
        .round()
        .toString()
        .replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ' ',
    );

    return '$formatted FCFA';
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder: (
          context,
          controller,
          child,
          ) {
        return MainLayout(
          title: 'Tableau de bord',
          actions: [
            IconButton(
              tooltip: 'Actualiser',
              icon: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFFFFC107),
                size: 22,
              ),
              onPressed: controller.isLoading
                  ? null
                  : controller.refreshDashboard,
            ),
          ],
          child: _buildBody(
            context,
            controller,
          ),
        );
      },
    );
  }

  // BODY
  Widget _buildBody(
      BuildContext context,
      DashboardController controller,
      ) {
    // CHARGEMENT INITIAL
    if (controller.isLoading &&
        controller.dashboardData == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFFC107),
        ),
      );
    }

    // ERREUR SANS DONNÉES
    if (controller.hasError &&
        controller.dashboardData == null) {
      return _buildErrorState(
        controller,
      );
    }

    // DASHBOARD
    return RefreshIndicator(
      color: const Color(0xFFFFC107),
      onRefresh: controller.refreshDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ERREUR NON BLOQUANTE
            if (controller.hasError)
              _buildErrorBanner(
                controller.errorMessage,
              ),

            // STATISTIQUES
            _buildStatsGrid(
              controller.stats,
            ),

            SizedBox(height: 32.h),

            // GRAPHIQUES
            _buildChartsLayout(
              controller.revenueData,
              controller.cities,
              controller.recentBookings,
            ),

            SizedBox(height: 32.h),

            // FOOTER
            const AppFooter(),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  // ERROR STATE
  Widget _buildErrorState(
      DashboardController controller,
      ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 52.sp,
              color: Colors.redAccent,
            ),

            SizedBox(height: 16.h),

            Text(
              'Impossible de charger le dashboard',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              controller.errorMessage.isEmpty
                  ? 'Une erreur est survenue.'
                  : controller.errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),

            SizedBox(height: 20.h),

            ElevatedButton.icon(
              onPressed:
              controller.refreshDashboard,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Réessayer',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ERROR BANNER
  Widget _buildErrorBanner(
      String message,
      ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: 16.h,
      ),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(
          alpha: 0.10,
        ),
        borderRadius:
        BorderRadius.circular(10.r),
        border: Border.all(
          color: Colors.redAccent.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.redAccent,
            size: 20,
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Text(
              message,
              style: GoogleFonts.manrope(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STATS GRID
  Widget _buildStatsGrid(
      DashboardStats stats,
      ) {
    final isDesktop =
    Responsive.isDesktop(context);

    final isTablet =
    Responsive.isTablet(context);

    final crossAxisCount = isDesktop
        ? 4
        : isTablet
        ? 3
        : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics:
      const NeverScrollableScrollPhysics(),
      gridDelegate:
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio:
        isDesktop ? 1.6 : 1.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 8,
      itemBuilder: (
          context,
          index,
          ) {
        switch (index) {
          case 0:
            return _buildPropertyCard(
              stats,
            );

          case 1:
            return StatsCard(
              title: 'Réservations',
              value:
              stats.totalReservations
                  .toString(),
              icon:
              Icons.calendar_today_rounded,
              color:
              const Color(0xFF3B82F6),
              subtitle:
              '+${stats.reservationsToday} aujourd\'hui',
              percentageChange: 12.5,
            );

          case 2:
            return StatsCard(
              title: 'En attente',
              value:
              stats.reservationsEnAttente
                  .toString(),
              icon:
              Icons.hourglass_empty_rounded,
              color:
              const Color(0xFFF59E0B),
              subtitle: 'À valider',
            );

          case 3:
            return StatsCard(
              title: 'Confirmées',
              value:
              stats.reservationsConfirmees
                  .toString(),
              icon:
              Icons.check_circle_rounded,
              color:
              const Color(0xFF10B981),
              subtitle:
              'Réservations validées',
            );

          case 4:
            return StatsCard(
              title: 'Terminées',
              value:
              stats.reservationsTerminees
                  .toString(),
              icon:
              Icons.done_all_rounded,
              color:
              const Color(0xFF8B5CF6),
              subtitle:
              'Réservations terminées',
            );

          case 5:
            return StatsCard(
              title: 'Locataires',
              value:
              stats.totalClients
                  .toString(),
              icon:
              Icons.people_alt_rounded,
              color:
              const Color(0xFFFF7900),
              subtitle:
              'Clients actifs',
            );

          case 6:
            return StatsCard(
              title: 'Propiétaires',
              value:
              stats.totalOwner
                  .toString(),
              icon:
              Icons.people_alt_rounded,
              color:
              const Color(0xFF0057FF),
              subtitle:
              'Proprétaire actifs',
            );

          case 7:
            return StatsCard(
              title: 'Frais de service',
              value: _formatMoney(stats.totalService),
              icon: Icons.monetization_on_rounded,
              color: const Color(0xFFFFE49D),
              subtitle: 'Total frais de service',
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  // PROPERTY CARD
  Widget _buildPropertyCard(
      DashboardStats stats,
      ) {
    final total =
        stats.totalAppartements + stats.totalVillas + stats.totalStudios;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111622),
        borderRadius:
        BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.05,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color:
                  const Color(0xFFE36830)
                      .withValues(
                    alpha: 0.15,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    8.r,
                  ),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color:
                  Color(0xFFE36830),
                  size: 20,
                ),
              ),

              SizedBox(width: 8.w),

              Expanded(
                child: Text(
                  'Biens immobiliers',
                  style: GoogleFonts.manrope(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                  overflow:
                  TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          Text(
            total.toString(),
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 26,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          SizedBox(height: 8.h),

          Row(
            children: [
              Expanded(
                child: _buildPropertyType(
                  icon:
                  Icons.apartment_rounded,
                  label: 'Apparts',
                  value:
                  stats.totalAppartements,
                  color:
                  const Color(0xFFE36830),
                ),
              ),

              SizedBox(width: 8.w),

              Expanded(
                child: _buildPropertyType(
                  icon:
                  Icons.house_rounded,
                  label: 'Villas',
                  value:
                  stats.totalVillas,
                  color:
                  Colors.orange,
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          Text(
            'Total des biens',
            style: GoogleFonts.manrope(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // PROPERTY TYPE
  Widget _buildPropertyType({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),

        SizedBox(width: 4.w),

        Flexible(
          child: Text(
            label,
            style: GoogleFonts.manrope(
              color: Colors.white54,
              fontSize: 13,
              fontWeight:
              FontWeight.w600,
            ),
            overflow:
            TextOverflow.ellipsis,
          ),
        ),

        SizedBox(width: 4.w),

        Text(
          value.toString(),
          style: GoogleFonts.manrope(
            color: color,
            fontSize: 20,
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // CHARTS
  Widget _buildChartsLayout(
      List<RevenueDataPoint> revenueData,
      List<CityStats> cities,
      List<BookingData> recentBookings,
      ) {
    final isDesktop =
    Responsive.isDesktop(context);

    return Column(
      children: [
        // REVENUS
        Container(
          width: double.infinity,
          padding:
          const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
            const Color(0xFF111622),
            borderRadius:
            BorderRadius.circular(10),
            border: Border.all(
              color:
              Colors.white.withValues(
                alpha: 0.05,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Revenus & Réservations',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w800,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Janvier — Décembre 2026',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 180,
                child: RevenueChart(
                  data: revenueData,
                  title: '',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // DESKTOP
        if (isDesktop)
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child:
                _buildDashboardPanel(
                  child:
                  TopCities(
                    cities: cities,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 6,
                child:
                _buildDashboardPanel(
                  child:
                  RecentBookings(
                    bookings:
                    recentBookings,
                  ),
                ),
              ),
            ],
          )

        // TABLET / MOBILE
        else ...[
          _buildDashboardPanel(
            child: TopCities(
              cities: cities,
            ),
          ),

          const SizedBox(height: 12),

          _buildDashboardPanel(
            child: RecentBookings(
              bookings: recentBookings,
            ),
          ),
        ],
      ],
    );
  }

  // PANEL
  Widget _buildDashboardPanel({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
        const Color(0xFF111622),
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color:
          Colors.white.withValues(
            alpha: 0.05,
          ),
        ),
      ),
      child: child,
    );
  }
}