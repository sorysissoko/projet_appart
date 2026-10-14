import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service/backend_service.dart';

import '../core/navigation/main_wrapper.dart';
import '../core/theme/app_theme.dart';

// MODÈLES
class StatItem {
  final String label;
  final String value;
  final String change;
  final bool up;
  final String icon;

  const StatItem({
    required this.label,
    required this.value,
    required this.change,
    required this.up,
    required this.icon,
  });
}

class AvailableApt {
  final String id;
  final String name;
  final String img;
  final String price;

  const AvailableApt({
    required this.id,
    required this.name,
    required this.img,
    required this.price,
  });
}

// ============================================================
// SKELETON CARDS
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
        width: double.infinity,
        height: 230,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.card,
              Color(0xFF2554EF),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 140,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 100,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildSkeletonRevenueTile(),
                  const SizedBox(width: 36),
                  _buildSkeletonRevenueTile(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonRevenueTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 50,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class _SkeletonStatCard extends StatefulWidget {
  const _SkeletonStatCard();

  @override
  State<_SkeletonStatCard> createState() => _SkeletonStatCardState();
}

class _SkeletonStatCardState extends State<_SkeletonStatCard>
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
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 50,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 80,
                  height: 13,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonApartmentCard extends StatefulWidget {
  const _SkeletonApartmentCard();

  @override
  State<_SkeletonApartmentCard> createState() => _SkeletonApartmentCardState();
}

class _SkeletonApartmentCardState extends State<_SkeletonApartmentCard>
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
        width: 150,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 90,
              color: const Color(0xFFE9EDF5),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 13,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FA),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEF2FA),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DASHBOARD PROPRIÉTAIRE
// ============================================================

class DashboardPage extends StatefulWidget {
  final NavigateCallback onNavigate;

  const DashboardPage({
    super.key,
    required this.onNavigate,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final BackendService _backendService = BackendService();

  // ==========================================================
  // ÉTAT
  // ==========================================================

  bool _loading = true;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _apartments = [];

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  // ==========================================================
  // CHARGEMENT
  // ==========================================================

  Future<void> _loadDashboard({
    bool refresh = false,
  }) async {
    if (refresh) {
      setState(() {});
    } else {
      setState(() {
        _loading = true;
      });
    }

    try {
      // ======================================================
      // CHARGER LES STATISTIQUES
      // ======================================================

      final stats = await _backendService.getOwnerDashboardStats();

      // ======================================================
      // CHARGER LES APPARTEMENTS
      // ======================================================

      final apartments = await _backendService.getOwnerApartments();

      if (!mounted) return;

      setState(() {
        _stats = stats;
        _apartments = apartments;
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ DashboardPage._loadDashboard: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildLoadingState();
    }

    return Container(
      color: AppColors.background,
      child: RefreshIndicator(
        color: const Color(0xFF3B82F6),
        onRefresh: () => _loadDashboard(refresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    height: 290,
                    color: AppColors.foreground,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _buildRevenueCard(),
                        Transform.translate(
                          offset: const Offset(0, -20),
                          child: _buildStatsGrid(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ==================================================
              // APPARTEMENTS
              // ==================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                child: _buildAvailableSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // LOADING STATE AVEC SKELETONS
  // ==========================================================

  Widget _buildLoadingState() {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 290,
                  color: AppColors.foreground,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      const _SkeletonRevenueCard(),
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.45,
                            ),
                            itemCount: 4,
                            itemBuilder: (context, index) => const _SkeletonStatCard(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 150,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FA),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 15,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FA),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 155,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const _SkeletonApartmentCard(),
                        const _SkeletonApartmentCard(),
                        const _SkeletonApartmentCard(),
                        Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 4, bottom: 4),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF93C5FD).withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: 32,
                                color: Color(0xFF3B82F6),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Ajouter',
                                style: GoogleFonts.nunito(
                                  color: Color(0xFF3B82F6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // CARTE REVENUS
  // ==========================================================

  Widget _buildRevenueCard() {
    final revenus = _toDouble(_stats['revenus']);
    final evolution = _toDouble(_stats['evolution_revenus']);
    final biens = _stats['biens'] ?? 0;
    final villes = _stats['villes'] ?? 0;
    final mois = _getCurrentMonthName();

    return Container(
      width: double.infinity,
      height: 230,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card,
            Color(0xFF2554EF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Cercle décoratif
          Positioned(
            right: -60,
            top: -50,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: -50,
            child: Container(
              width: 90,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Contenu
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revenus $mois',
                  style: GoogleFonts.nunito(
                    color: const Color(0xFFBFDBFE),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _formatMoney(revenus),
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatEvolution(evolution),
                    style: GoogleFonts.nunito(
                      color: const Color(0xFF34D399),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _RevenueStatTile(
                      label: '$biens biens',
                      sub: 'Appartements',
                    ),
                    const SizedBox(width: 36),
                    _RevenueStatTile(
                      label: '$villes villes',
                      sub: 'Localisations',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // GRILLE STATISTIQUES
  // ==========================================================

  Widget _buildStatsGrid() {
    final reservations = _stats['reservations'] ?? 0;
    final taux = _toDouble(_stats['taux_occupation']);
    final note = _toDouble(_stats['note']);
    final avis = _stats['avis'] ?? 0;

    final stats = [
      StatItem(
        label: 'Revenus ce mois',
        value: _formatMoney(_toDouble(_stats['revenus'])),
        change: _formatEvolutionShort(_toDouble(_stats['evolution_revenus'])),
        up: _toDouble(_stats['evolution_revenus']) >= 0,
        icon: '💰',
      ),
      StatItem(
        label: 'Réservations actives',
        value: reservations.toString(),
        change: 'En cours',
        up: true,
        icon: '📅',
      ),
      StatItem(
        label: 'Taux occupation',
        value: '${taux.toStringAsFixed(0)}%',
        change: '${_stats['nuits_occupees'] ?? 0} nuits',
        up: taux >= 0,
        icon: '📊',
      ),
      StatItem(
        label: 'Avis clients',
        value: note > 0 ? '${note.toStringAsFixed(1)} ★' : '—',
        change: '$avis avis',
        up: note > 0,
        icon: '⭐',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.45,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];

        return Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.icon,
                    style: GoogleFonts.nunito(fontSize: 22),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: stat.up ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        stat.change,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: stat.up ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.value,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: const Color(0xFF1E3A5F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // APPARTEMENTS DISPONIBLES
  Widget _buildAvailableSection() {
    final disponibles = _getAvailableApartments();

    // Maximum 5 appartements affichés sur le dashboard
    final appartementsAffiches = disponibles.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Disponibles maintenant',
          onActionTap: () {
            widget.onNavigate(AppPage.mesAppartements);
          },
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 155,
          child: appartementsAffiches.isEmpty
              ? _buildEmptyApartments()
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: appartementsAffiches.length + 1,
            itemBuilder: (context, index) {
              // Carte "Ajouter"
              if (index == appartementsAffiches.length) {
                return _buildAddApartmentCard();
              }

              return _AvailableCard(
                item: appartementsAffiches[index],
              );
            },
          ),
        ),
      ],
    );
  }

  // APPARTEMENTS DISPONIBLES
  List<AvailableApt> _getAvailableApartments() {
    final result = <AvailableApt>[];

    final maintenant = DateTime.now();

    for (final apartment in _apartments) {
      final validationStatus =
      apartment['status']?.toString().toLowerCase().trim();

      final disponibiliteStatus =
      apartment['disponibilite_status']?.toString().toLowerCase().trim();

      // ============================================================
      // 1. L'APPARTEMENT DOIT ÊTRE PUBLIE
      // ============================================================

      if (validationStatus != 'publie') {
        continue;
      }

      // ============================================================
      // 2. L'APPARTEMENT DOIT ÊTRE DISPONIBLE
      // ============================================================

      if (disponibiliteStatus != 'disponible') {
        continue;
      }

      // ============================================================
      // 3. VERIFIER LES RESERVATIONS
      // ============================================================

      final reservations = apartment['reservations'];

      bool estReserveMaintenant = false;

      if (reservations is List) {
        for (final reservation in reservations) {
          if (reservation is! Map) continue;

          final statut =
          reservation['statut']?.toString().toLowerCase().trim();

          // On ne considère comme bloquantes que les réservations
          // confirmées.
          if (statut != 'confirmee') {
            continue;
          }

          final dateDebutString =
          reservation['date_debut']?.toString();

          final dateFinString =
          reservation['date_fin']?.toString();

          if (dateDebutString == null ||
              dateFinString == null ||
              dateDebutString.isEmpty ||
              dateFinString.isEmpty) {
            continue;
          }

          final dateDebut = DateTime.tryParse(dateDebutString);
          final dateFin = DateTime.tryParse(dateFinString);

          if (dateDebut == null || dateFin == null) {
            continue;
          }

          // On compare uniquement les dates.
          final aujourdHui = DateTime(
            maintenant.year,
            maintenant.month,
            maintenant.day,
          );

          final debut = DateTime(
            dateDebut.year,
            dateDebut.month,
            dateDebut.day,
          );

          final fin = DateTime(
            dateFin.year,
            dateFin.month,
            dateFin.day,
          );

          // ========================================================
          // RESERVATION ACTIVE AUJOURD'HUI
          // ========================================================

          if (!aujourdHui.isBefore(debut) &&
              aujourdHui.isBefore(fin)) {
            estReserveMaintenant = true;
            break;
          }
        }
      }

      // ============================================================
      // 4. SI RESERVE → NE PAS AFFICHER
      // ============================================================

      if (estReserveMaintenant) {
        continue;
      }

      // ============================================================
      // 5. RECUPERER LA PHOTO
      // ============================================================

      final photos = apartment['photo_appartements'];

      String image = '';

      if (photos is List && photos.isNotEmpty) {
        final sortedPhotos = List<Map<String, dynamic>>.from(
          photos.map(
                (e) => Map<String, dynamic>.from(e),
          ),
        );

        sortedPhotos.sort((a, b) {
          final ordreA =
              int.tryParse(
                a['ordre_affichage']?.toString() ?? '0',
              ) ??
                  0;

          final ordreB =
              int.tryParse(
                b['ordre_affichage']?.toString() ?? '0',
              ) ??
                  0;

          return ordreA.compareTo(ordreB);
        });

        // ========================================================
        // PRIORITE A LA PHOTO PRINCIPALE
        // ========================================================

        Map<String, dynamic>? photoPrincipale;

        for (final photo in sortedPhotos) {
          if (photo['est_principale'] == true) {
            photoPrincipale = photo;
            break;
          }
        }

        final photo =
            photoPrincipale ?? sortedPhotos.first;

        final filename =
            photo['fichiername']?.toString() ?? '';

        final appartementId =
            apartment['id']?.toString() ?? '';

        if (filename.isNotEmpty &&
            appartementId.isNotEmpty) {
          image =
          'https://rcaujtlhfyumkuwdfpcm.supabase.co/'
              'storage/v1/object/public/appartements/'
              '$appartementId/$filename';
        }
      }

      // ============================================================
      // 6. AJOUTER A LA LISTE
      // ============================================================

      result.add(
        AvailableApt(
          id: apartment['id']?.toString() ?? '',
          name: apartment['titre']?.toString() ?? 'Appartement',
          img: image,
          price:
          '${_formatNumber(_toDouble(apartment['prix']))} FCFA/nuit',
        ),
      );
    }

    return result;
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyApartments() {
    return Row(
      children: [
        Container(
          width: 150,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              'Aucun bien disponible',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                color: const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        _buildAddApartmentCard(),
      ],
    );
  }

  // ==========================================================
  // AJOUTER APPARTEMENT
  // ==========================================================

  Widget _buildAddApartmentCard() {
    return GestureDetector(
      onTap: () {
        widget.onNavigate(AppPage.ajouterAppartement);
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 4, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF93C5FD).withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              size: 32,
              color: Color(0xFF3B82F6),
            ),
            SizedBox(height: 4),
            Text(
              'Ajouter',
              style: GoogleFonts.nunito(
                color: Color(0xFF3B82F6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // UTILITAIRES
  // ==========================================================

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '.')) ?? 0;
  }

  String _formatMoney(double value) {
    final rounded = value.round();
    final text = rounded.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    return '${buffer.toString()} FCFA';
  }

  String _formatNumber(double value) {
    final rounded = value.round();
    final text = rounded.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    return buffer.toString();
  }

  String _formatEvolution(double value) {
    if (value > 0) return '↑ +${value.toStringAsFixed(0)}% vs mois dernier';
    if (value < 0) return '↓ ${value.toStringAsFixed(0)}% vs mois dernier';
    return '→ 0% vs mois dernier';
  }

  String _formatEvolutionShort(double value) {
    if (value > 0) return '+${value.toStringAsFixed(0)}%';
    if (value < 0) return '${value.toStringAsFixed(0)}%';
    return '0%';
  }

  String _getCurrentMonthName() {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return months[DateTime.now().month - 1];
  }
}

// ============================================================
// MINI STATISTIQUE
// ============================================================

class _RevenueStatTile extends StatelessWidget {
  final String label;
  final String sub;

  const _RevenueStatTile({
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          style: GoogleFonts.nunito(
            color: const Color(0xFF93C5FD),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// HEADER SECTION
// ============================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onActionTap;

  const _SectionHeader({
    required this.title,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onActionTap,
          child: Text(
            'Voir tout',
            style: GoogleFonts.nunito(
              color: const Color(0xFFD97706),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// CARTE APPARTEMENT
// ============================================================

class _AvailableCard extends StatelessWidget {
  final AvailableApt item;

  const _AvailableCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================
          // IMAGE
          // ==================================================

          item.img.isNotEmpty
              ? Image.network(
            item.img,
            width: double.infinity,
            height: 90,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildImagePlaceholder(loading: true);
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder();
            },
          )
              : _buildImagePlaceholder(),

          // ==================================================
          // INFORMATIONS
          // ==================================================

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: const Color(0xFF0F1B2D),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        item.price,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: const Color(0xFFC9913A),
                        ),
                      ),
                    ),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder({bool loading = false}) {
    return Container(
      width: double.infinity,
      height: 90,
      color: const Color(0xFFE9EDF5),
      child: Center(
        child: loading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF3B82F6),
          ),
        )
            : const Icon(
          Icons.image_outlined,
          color: Color(0xFF8A94A6),
          size: 30,
        ),
      ),
    );
  }
}