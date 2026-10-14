import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:service/database_service.dart';

import '../../../routes.dart';
import '../../providers/user_provider.dart';
import '../../screens/notifications/notification_service.dart';
import '../../screens/notifications/notifications_page.dart';

class SideMenu extends StatefulWidget {
  final bool isCollapsed;
  final Function(String)? onNavigate;

  const SideMenu({
    super.key,
    required this.isCollapsed,
    this.onNavigate,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // ÉTATS
  // ============================================================

  final Set<String> _expandedCities = {};

  String _currentRoute = '';

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  // ============================================================
  // RÉSERVATIONS
  // ============================================================

  int _pendingReservationsCount = 0;

  bool _hasBeenNotified = false;

  Timer? _notificationTimer;

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  final NotificationService _notificationService =
  NotificationService();

  StreamSubscription<NotificationRealtimeEvent>?
  _notificationSubscription;

  int _unreadNotificationCount = 0;

  // ============================================================
  // STYLE
  // ============================================================

  static const Color _primaryColor =
  Color(0xFFFFC107);

  static const Color _backgroundColor =
  Color(0xFF090D16);

  static const Color _surfaceColor =
  Color(0xFF111622);

  // ============================================================
  // ROUTES VILLES
  // ============================================================

  static const Map<String, Map<String, String>>
  _cityRoutes = {
    'Bamako': {
      'Appartements': '/list_appart_bamako',
      'Villas': '/list_villa_bamako',
      'Studios': '/list_studio_bamako',
    },
    'Kayes': {
      'Appartements': '/list_appart_kayes',
      'Villas': '/list_villa_kayes',
      'Studios': '/list_studio_kayes',
    },
    'Koulikoro': {
      'Appartements': '/list_appart_koulikoro',
      'Villas': '/list_villa_koulikoro',
      'Studios': '/list_studio_koukikoro',
    },
    'Sikasso': {
      'Appartements': '/list_appart_sikasso',
      'Villas': '/list_villa_sikasso',
      'Studios': '/list_studio_sikasso',
    },
    'Ségou': {
      'Appartements': '/list_appart_segou',
      'Villas': '/list_villa_segou',
      'Studios': '/list_studio_segou',
    },
    'Bougouni': {
      'Appartements': '/list_appart_bougouni',
      'Villas': '/list_villa_bougouni',
      'Studios': '/list_studio_bougouni',
    },
    'Koutiala': {
      'Appartements': '/list_appart_koutiala',
      'Villas': '/list_villa_koutiala',
      'Studios': '/list_studio_koutiala',
    },
  };

  // ============================================================
  // SERVICES
  // ============================================================

  final DatabaseService _dbService =
  DatabaseService();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Animation
    _animationController = AnimationController(
      duration:
      const Duration(milliseconds: 250),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    // ----------------------------------------------------------
    // RÉSERVATIONS
    // ----------------------------------------------------------

    _loadPendingReservationsCount();

    _notificationTimer = Timer.periodic(
      const Duration(seconds: 30),
          (_) {
        _checkForNewReservations();
      },
    );

    // ----------------------------------------------------------
    // NOTIFICATIONS
    // ----------------------------------------------------------

    _loadUnreadNotificationCount();

    _notificationService.startRealtime();

    _notificationSubscription =
        _notificationService.events.listen(
          _handleNotificationEvent,
        );
  }


  void _showNotificationsModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notifications',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (
          context,
          animation,
          secondaryAnimation,
          ) {
        return const NotificationsPage();
      },
      transitionBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
          ) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.94,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
  // ============================================================
  // ROUTE
  // ============================================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final routeName =
        ModalRoute.of(context)?.settings.name;

    if (routeName != null &&
        routeName != _currentRoute) {
      _currentRoute = routeName;

      _autoExpandActiveCity();

      if (mounted) {
        setState(() {});
      }
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _notificationTimer?.cancel();

    _notificationSubscription?.cancel();

    _animationController.dispose();

    super.dispose();
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Future<void>
  _loadUnreadNotificationCount() async {
    try {
      final count =
      await _notificationService
          .getUnreadCount();

      if (!mounted) return;

      setState(() {
        _unreadNotificationCount = count;
      });
    } catch (e) {
      debugPrint(
        '❌ Erreur compteur notifications : $e',
      );
    }
  }

  void _handleNotificationEvent(
      NotificationRealtimeEvent event,
      ) {
    if (!mounted) return;

    setState(() {
      switch (event.type) {
      // ------------------------------------------------------
      // INSERT
      // ------------------------------------------------------

        case NotificationRealtimeType.inserted:
          final isRead =
              event.newIsRead ?? false;

          if (!isRead) {
            _unreadNotificationCount++;
          }

          break;

      // ------------------------------------------------------
      // UPDATE
      // ------------------------------------------------------

        case NotificationRealtimeType.updated:
          final oldRead =
              event.oldIsRead ?? false;

          final newRead =
              event.newIsRead ?? false;

          // Non lue -> lue
          if (!oldRead && newRead) {
            _unreadNotificationCount--;

            if (_unreadNotificationCount < 0) {
              _unreadNotificationCount = 0;
            }
          }

          // Lue -> non lue
          if (oldRead && !newRead) {
            _unreadNotificationCount++;
          }

          break;

      // ------------------------------------------------------
      // DELETE
      // ------------------------------------------------------

        case NotificationRealtimeType.deleted:
          final wasUnread =
              event.oldIsRead == false;

          if (wasUnread) {
            _unreadNotificationCount--;

            if (_unreadNotificationCount < 0) {
              _unreadNotificationCount = 0;
            }
          }

          break;
      }
    });
  }

  String? _getNotificationBadgeText() {
    if (_unreadNotificationCount <= 0) {
      return null;
    }

    if (_unreadNotificationCount > 99) {
      return '99+';
    }

    return _unreadNotificationCount.toString();
  }

  // ============================================================
  // RÉSERVATIONS — ADMIN
  // ============================================================

  Future<void>
  _loadPendingReservationsCount() async {
    try {
      final user =
          _dbService.supabase.auth.currentUser;

      if (user == null) return;

      // IMPORTANT :
      // L'admin doit voir toutes les réservations
      // en attente, pas seulement celles de ses
      // propres appartements.

      final reservations =
      await _dbService.supabase
          .from('reservations')
          .select('id')
          .eq(
        'statut',
        'en_attente',
      );

      final newCount =
          reservations.length;

      if (newCount >
          _pendingReservationsCount &&
          !_hasBeenNotified &&
          newCount > 0 &&
          mounted) {
        _showNotificationBanner(
          newCount,
        );

        _hasBeenNotified = true;
      }

      if (mounted) {
        setState(() {
          _pendingReservationsCount =
              newCount;
        });
      }
    } catch (e) {
      debugPrint(
        '❌ Erreur chargement réservations : $e',
      );
    }
  }

  Future<void>
  _checkForNewReservations() async {
    try {
      final user =
          _dbService.supabase.auth.currentUser;

      if (user == null) return;

      final reservations =
      await _dbService.supabase
          .from('reservations')
          .select('id')
          .eq(
        'statut',
        'en_attente',
      );

      final newCount =
          reservations.length;

      if (newCount >
          _pendingReservationsCount &&
          !_hasBeenNotified &&
          newCount > 0 &&
          mounted) {
        _showNotificationBanner(
          newCount,
        );

        _hasBeenNotified = true;
      }

      if (mounted) {
        setState(() {
          _pendingReservationsCount =
              newCount;
        });
      }
    } catch (e) {
      debugPrint(
        '❌ Erreur vérification réservations : $e',
      );
    }
  }

  // ============================================================
  // BANNER RÉSERVATIONS
  // ============================================================

  void _showNotificationBanner(
      int count,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentMaterialBanner();

    ScaffoldMessenger.of(context)
        .showMaterialBanner(
      MaterialBanner(
        backgroundColor:
        const Color(0xFF1A1A2E),

        content: Row(
          children: [
            Container(
              padding:
              EdgeInsets.all(8.w),
              decoration:
              const BoxDecoration(
                color:
                Color(0xFFFFC107),
                shape:
                BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active,
                color:
                const Color(0xFF090D16),
                size: 20.sp,
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Text(
                    '$count nouvelle${count > 1 ? 's' : ''} réservation${count > 1 ? 's' : ''} en attente',
                    style:
                    GoogleFonts.manrope(
                      color:
                      Colors.white,
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  Text(
                    'Cliquez pour voir les réservations',
                    style:
                    GoogleFonts.manrope(
                      color:
                      Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).hideCurrentMaterialBanner();

              _navigateTo(
                AppRoutes.reservations,
              );
            },
            child: Text(
              'VOIR',
              style:
              GoogleFonts.manrope(
                color:
                const Color(0xFFFFC107),
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).hideCurrentMaterialBanner();
            },
            icon: const Icon(
              Icons.close,
              color:
              Colors.white54,
              size: 18,
            ),
          ),
        ],

        leading:
        const SizedBox.shrink(),
      ),
    );
  }

  void _markReservationsAsSeen() {
    if (_currentRoute ==
        AppRoutes.reservations) {
      _hasBeenNotified = false;
    }
  }

  String _getReservationBadgeText() {
    if (_pendingReservationsCount <= 0) {
      return '';
    }

    if (_pendingReservationsCount > 9) {
      return '9+';
    }

    return _pendingReservationsCount
        .toString();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _autoExpandActiveCity() {
    _cityRoutes.forEach(
          (city, routes) {
        if (routes.containsValue(
          _currentRoute,
        ) &&
            !_expandedCities
                .contains(city)) {
          _expandedCities.add(city);
        }
      },
    );
  }

  void _navigateTo(
      String route,
      ) {
    if (route ==
        AppRoutes.reservations) {
      _markReservationsAsSeen();
    }

    widget.onNavigate?.call(route);
  }

  void _navigateToProperty(
      String city,
      String propertyType,
      ) {
    final route =
    _cityRoutes[city]?[propertyType];

    if (route != null &&
        route.isNotEmpty) {
      _expandedCities.add(city);

      widget.onNavigate?.call(route);
    }
  }

  void _toggleCityExpansion(
      String city,
      ) {
    setState(() {
      if (_expandedCities
          .contains(city)) {
        _expandedCities.remove(city);
      } else {
        _expandedCities.add(city);
      }
    });
  }

  bool _isRouteActive(
      String route,
      ) {
    return _currentRoute == route;
  }

  bool _isVillesSectionActive() {
    return _cityRoutes.values.any(
          (routes) => routes.containsValue(
        _currentRoute,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return FadeTransition(
      opacity: _animation,
      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: widget.isCollapsed
            ? 70.w
            : 290.w,
        decoration:
        const BoxDecoration(
          color: _backgroundColor,
          border: Border(
            right: BorderSide(
              color: Colors.white10,
              width: 1.5,
            ),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: _buildMenuList(),
            ),

            _buildUserSection(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER SIDEBAR
  // ============================================================

  Widget _buildHeader() {
    return Container(
      padding:
      EdgeInsets.symmetric(
        vertical: 3.h,
        horizontal: 16.w,
      ),
      height: 90.h,
      child: AnimatedEndTransition(
        isCollapsed:
        widget.isCollapsed,

        expandedWidget: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration:
              BoxDecoration(
                color:
                _primaryColor,
                borderRadius:
                BorderRadius
                    .circular(10.r),
              ),
              child: const Icon(
                Icons.apartment_rounded,
                color:
                _backgroundColor,
                size: 22,
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                children: [
                  Text(
                    'DS Appart',
                    style:
                    GoogleFonts.manrope(
                      color:
                      Colors.white,
                      fontSize:
                      35.sp,
                      fontWeight:
                      FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                  ),

                  Text(
                    'Gestion Immobilière',
                    style:
                    GoogleFonts.manrope(
                      color:
                      Colors.white38,
                      fontSize:
                      15.sp,
                    ),
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        collapsedWidget:
        const Center(
          child: Icon(
            Icons.apartment_rounded,
            color:
            _primaryColor,
            size: 26,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MENU
  // ============================================================

  Widget _buildMenuList() {
    return SingleChildScrollView(
      physics:
      const BouncingScrollPhysics(),
      padding:
      EdgeInsets.symmetric(
        vertical: 8.h,
      ),
      child: Column(
        children: [
          // ------------------------------------------------------
          // DASHBOARD
          // ------------------------------------------------------

          _MenuItem(
            icon:
            Icons.grid_view_rounded,
            label:
            'Tableau de bord',
            isActive:
            _isRouteActive(
              AppRoutes.dashboard,
            ),
            isCollapsed:
            widget.isCollapsed,
            onTap: () =>
                _navigateTo(
                  AppRoutes.dashboard,
                ),
          ),

          // ------------------------------------------------------
          // VILLES
          // ------------------------------------------------------

          _VillesSection(
            isCollapsed:
            widget.isCollapsed,
            isActive:
            _isVillesSectionActive(),
            expandedCities:
            _expandedCities,
            cityRoutes:
            _cityRoutes,
            currentRoute:
            _currentRoute,
            onToggleCity:
            _toggleCityExpansion,
            onNavigate:
            _navigateToProperty,
          ),

          // ------------------------------------------------------
          // LOCATAIRES
          // ------------------------------------------------------

          _MenuItem(
            icon:
            Icons.people_outline_rounded,
            label:
            'Locataires',
            isActive:
            _isRouteActive(
              AppRoutes.users,
            ),
            isCollapsed:
            widget.isCollapsed,
            onTap: () =>
                _navigateTo(
                  AppRoutes.users,
                ),
          ),

          // ------------------------------------------------------
          // PROPRIÉTAIRES
          // ------------------------------------------------------

          _MenuItem(
            icon:
            Icons.people_outline_rounded,
            label:
            'Propriétaires',
            isActive:
            _isRouteActive(
              AppRoutes.owners,
            ),
            isCollapsed:
            widget.isCollapsed,
            onTap: () =>
                _navigateTo(
                  AppRoutes.owners,
                ),
          ),

          // ------------------------------------------------------
          // NOTIFICATIONS
          // ------------------------------------------------------

          _MenuItem(
            icon:
            Icons.notifications_none_rounded,
            label:
            'Notifications',
            isActive:
            _isRouteActive(
              AppRoutes.notification,
            ),
            isCollapsed:
            widget.isCollapsed,
            badge:
            _getNotificationBadgeText() ??
                '',
            onTap: () => _showNotificationsModal(context),
          ),

          // ------------------------------------------------------
          // RÉSERVATIONS
          // ------------------------------------------------------

          _MenuItem(
            icon:
            Icons.calendar_today_outlined,
            label:
            'Réservations',
            isActive:
            _isRouteActive(
              AppRoutes.reservations,
            ),
            isCollapsed:
            widget.isCollapsed,
            badge:
            _getReservationBadgeText(),
            onTap: () =>
                _navigateTo(
                  AppRoutes.reservations,
                ),
          ),

          // ------------------------------------------------------
          // DIVIDER
          // ------------------------------------------------------

          Padding(
            padding:
            EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            child: const Divider(
              color:
              Colors.white10,
              height: 1,
              thickness: 1,
            ),
          ),

          // ------------------------------------------------------
          // PARAMÈTRES
          // ------------------------------------------------------

          _MenuItem(
            icon:
            Icons.settings_outlined,
            label:
            'Paramètres',
            isActive:
            _isRouteActive(
              AppRoutes.settings,
            ),
            isCollapsed:
            widget.isCollapsed,
            onTap: () =>
                _navigateTo(
                  AppRoutes.settings,
                ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // USER SECTION
  // ============================================================

  Widget _buildUserSection() {
    return SafeArea(
      top: false,
      child: Container(
        padding:
        EdgeInsets.all(12.w),
        child:
        Consumer<UserProvider>(
          builder: (
              context,
              userProvider,
              _,
              ) {
            if (userProvider
                .isLoading) {
              return _LoadingWidget(
                isCollapsed:
                widget.isCollapsed,
                surfaceColor:
                _surfaceColor,
                primaryColor:
                _primaryColor,
              );
            }

            return _UserWidget(
              isCollapsed:
              widget.isCollapsed,
              surfaceColor:
              _surfaceColor,
              primaryColor:
              _primaryColor,
              initial:
              userProvider
                  .isAuthenticated
                  ? userProvider
                  .initial
                  : '?',
              displayName:
              userProvider
                  .isAuthenticated
                  ? userProvider
                  .displayName
                  : 'Non connecté',
              role:
              userProvider
                  .isAuthenticated
                  ? userProvider.role
                  : 'Invité',
              email:
              userProvider
                  .isAuthenticated
                  ? userProvider.email
                  : '',
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// MENU ITEM
// ============================================================

class _MenuItem extends StatelessWidget {
  final IconData icon;

  final String label;

  final bool isActive;

  final bool isCollapsed;

  final String badge;

  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isCollapsed,
    required this.onTap,
    this.badge = '',
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    const activeColor =
    Color(0xFFFFC107);

    return Padding(
      padding:
      EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 4.h,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(8.r),
        child: AnimatedContainer(
          duration:
          const Duration(
            milliseconds: 200,
          ),
          padding:
          EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 12.h,
          ),
          decoration:
          BoxDecoration(
            color: isActive
                ? activeColor.withValues(
              alpha: 0.08,
            )
                : Colors.transparent,
            borderRadius:
            BorderRadius.circular(8.r),
            border: Border.all(
              color: isActive
                  ? activeColor.withValues(
                alpha: 0.2,
              )
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment:
            isCollapsed
                ? MainAxisAlignment
                .center
                : MainAxisAlignment
                .start,
            children: [
              Stack(
                clipBehavior:
                Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isActive
                        ? activeColor
                        : Colors.white60,
                    size: 22.sp,
                  ),

                  // Badge ouvert
                  if (badge.isNotEmpty &&
                      !isCollapsed)
                    Positioned(
                      right: -6.w,
                      top: -6.h,
                      child:
                      _AnimatedBadge(
                        count: badge,
                      ),
                    ),

                  // Point rouge collapsed
                  if (badge.isNotEmpty &&
                      isCollapsed)
                    Positioned(
                      right: -4.w,
                      top: -4.h,
                      child:
                      Container(
                        width: 10.w,
                        height: 10.w,
                        decoration:
                        const BoxDecoration(
                          color:
                          Colors.red,
                          shape:
                          BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),

              if (!isCollapsed) ...[
                SizedBox(width: 12.w),

                Expanded(
                  child: Text(
                    label,
                    style:
                    GoogleFonts.manrope(
                      color: isActive
                          ? activeColor
                          : Colors.white70,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontSize: 20.sp,
                    ),
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BADGE ANIMÉ
// ============================================================

class _AnimatedBadge
    extends StatefulWidget {
  final String count;

  const _AnimatedBadge({
    required this.count,
  });

  @override
  State<_AnimatedBadge> createState() =>
      _AnimatedBadgeState();
}

class _AnimatedBadgeState
    extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController
  _controller;

  late Animation<double>
  _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(
          duration:
          const Duration(
            milliseconds: 300,
          ),
          vsync: this,
        );

    _scaleAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve:
            Curves.elasticOut,
          ),
        );

    _controller.forward();
  }

  @override
  void didUpdateWidget(
      _AnimatedBadge oldWidget,
      ) {
    super.didUpdateWidget(
      oldWidget,
    );

    if (widget.count !=
        oldWidget.count) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding:
        EdgeInsets.symmetric(
          horizontal: 5.w,
          vertical: 2.h,
        ),
        decoration:
        BoxDecoration(
          color: Colors.red,
          borderRadius:
          BorderRadius.circular(
            10.r,
          ),
          boxShadow: [
            BoxShadow(
              color:
              Colors.red.withValues(
                alpha: 0.4,
              ),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        constraints:
        BoxConstraints(
          minWidth: 18.w,
        ),
        child: Text(
          widget.count,
          style:
          GoogleFonts.manrope(
            color:
            Colors.white,
            fontSize:
            10.sp,
            fontWeight:
            FontWeight.bold,
          ),
          textAlign:
          TextAlign.center,
        ),
      ),
    );
  }
}

// ============================================================
// VILLES
// ============================================================

class _VillesSection
    extends StatelessWidget {
  final bool isCollapsed;

  final bool isActive;

  final Set<String>
  expandedCities;

  final Map<String,
      Map<String, String>>
  cityRoutes;

  final String currentRoute;

  final Function(String)
  onToggleCity;

  final Function(
      String,
      String,
      ) onNavigate;

  const _VillesSection({
    required this.isCollapsed,
    required this.isActive,
    required this.expandedCities,
    required this.cityRoutes,
    required this.currentRoute,
    required this.onToggleCity,
    required this.onNavigate,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    const activeColor =
    Color(0xFFFFC107);

    if (isCollapsed) {
      return Padding(
        padding:
        EdgeInsets.symmetric(
          vertical: 8.h,
        ),
        child: Icon(
          Icons.location_on_outlined,
          color: isActive
              ? activeColor
              : Colors.white60,
          size: 26.sp,
        ),
      );
    }

    return Padding(
      padding:
      EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 4.h,
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
            EdgeInsets.symmetric(
              horizontal: 12.w,
            ),
            visualDensity:
            VisualDensity.compact,
            leading: Icon(
              Icons.location_on_outlined,
              color: isActive
                  ? activeColor
                  : Colors.white60,
              size: 28.sp,
            ),
            title: Text(
              'Villes',
              style:
              GoogleFonts.manrope(
                color: isActive
                    ? activeColor
                    : Colors.white70,
                fontWeight: isActive
                    ? FontWeight.w600
                    : FontWeight.w400,
                fontSize: 20.sp,
              ),
            ),
          ),

          ...cityRoutes.keys.map(
                (city) {
              final citySpecificRoutes =
                  cityRoutes[city] ??
                      {};

              final isCityActive =
              citySpecificRoutes
                  .values
                  .contains(
                currentRoute,
              );

              final isExpanded =
              expandedCities
                  .contains(city);

              return _CityItem(
                city: city,
                isExpanded:
                isExpanded,
                isActive:
                isCityActive,
                citySpecificRoutes:
                citySpecificRoutes,
                currentRoute:
                currentRoute,
                onToggle:
                    () => onToggleCity(
                  city,
                ),
                onNavigate:
                    (propertyType) =>
                    onNavigate(
                      city,
                      propertyType,
                    ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CITY ITEM
// ============================================================

class _CityItem
    extends StatelessWidget {
  final String city;

  final bool isExpanded;

  final bool isActive;

  final Map<String, String>
  citySpecificRoutes;

  final String currentRoute;

  final VoidCallback onToggle;

  final Function(String)
  onNavigate;

  const _CityItem({
    required this.city,
    required this.isExpanded,
    required this.isActive,
    required this.citySpecificRoutes,
    required this.currentRoute,
    required this.onToggle,
    required this.onNavigate,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    const activeColor =
    Color(0xFFFFC107);

    return Container(
      margin:
      EdgeInsets.only(
        left: 12.w,
        top: 2.h,
      ),
      decoration:
      BoxDecoration(
        border:
        Border(
          left: BorderSide(
            color: isActive
                ? activeColor
                .withValues(
              alpha: 0.5,
            )
                : Colors.white10,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding:
              EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_city_rounded,
                    color: isActive
                        ? activeColor
                        : Colors.white38,
                    size: 20.sp,
                  ),

                  SizedBox(
                    width: 8.w,
                  ),

                  Expanded(
                    child: Text(
                      city,
                      style:
                      GoogleFonts.manrope(
                        color: isActive
                            ? Colors.white
                            : Colors.white54,
                        fontSize:
                        18.sp,
                        fontWeight:
                        isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),

                  Icon(
                    isExpanded
                        ? Icons
                        .keyboard_arrow_up
                        : Icons
                        .keyboard_arrow_down,
                    color:
                    Colors.white38,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild:
            const SizedBox.shrink(),

            secondChild: Padding(
              padding:
              EdgeInsets.only(
                left: 8.w,
                bottom: 6.h,
              ),
              child: Column(
                children:
                citySpecificRoutes.keys
                    .map(
                      (propertyType) {
                    final route =
                    citySpecificRoutes[
                    propertyType];

                    final isPropertyActive =
                        route ==
                            currentRoute;

                    return _PropertyItem(
                      propertyType:
                      propertyType,
                      isActive:
                      isPropertyActive,
                      onTap: () =>
                          onNavigate(
                            propertyType,
                          ),
                    );
                  },
                ).toList(),
              ),
            ),

            crossFadeState:
            isExpanded
                ? CrossFadeState
                .showSecond
                : CrossFadeState
                .showFirst,

            duration:
            const Duration(
              milliseconds: 200,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROPERTY ITEM
// ============================================================

class _PropertyItem
    extends StatelessWidget {
  final String propertyType;

  final bool isActive;

  final VoidCallback onTap;

  const _PropertyItem({
    required this.propertyType,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    const activeColor =
    Color(0xFFFFC107);

    return Padding(
      padding:
      EdgeInsets.symmetric(
        vertical: 2.h,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(6.r),
        child: AnimatedContainer(
          duration:
          const Duration(
            milliseconds: 150,
          ),
          padding:
          EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 6.h,
          ),
          decoration:
          BoxDecoration(
            color: isActive
                ? activeColor.withValues(
              alpha: 0.12,
            )
                : Colors.transparent,
            borderRadius:
            BorderRadius.circular(6.r),
          ),
          child: Row(
            children: [
              Icon(
                _getIconForPropertyType(
                  propertyType,
                ),
                color: isActive
                    ? activeColor
                    : Colors.white38,
                size: 24.sp,
              ),

              SizedBox(
                width: 8.w,
              ),

              Expanded(
                child: Text(
                  propertyType,
                  style:
                  GoogleFonts.manrope(
                    color: isActive
                        ? activeColor
                        : Colors.white70,
                    fontSize: 16.sp,
                    fontWeight: isActive
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData
  _getIconForPropertyType(
      String type,
      ) {
    switch (type) {
      case 'Appartements':
        return Icons
            .apartment_rounded;

      case 'Villas':
        return Icons.house_rounded;

      case 'Studios':
        return Icons.apartment_rounded;

      default:
        return Icons.circle_rounded;
    }
  }
}

// ============================================================
// TRANSITION
// ============================================================

class AnimatedEndTransition
    extends StatelessWidget {
  final bool isCollapsed;

  final Widget expandedWidget;

  final Widget collapsedWidget;

  const AnimatedEndTransition({
    super.key,
    required this.isCollapsed,
    required this.expandedWidget,
    required this.collapsedWidget,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return AnimatedSwitcher(
      duration:
      const Duration(
        milliseconds: 200,
      ),
      transitionBuilder:
          (child, anim) {
        return FadeTransition(
          opacity: anim,
          child: child,
        );
      },
      child: isCollapsed
          ? SizedBox(
        key:
        const ValueKey('c'),
        child:
        collapsedWidget,
      )
          : SizedBox(
        key:
        const ValueKey('e'),
        child:
        expandedWidget,
      ),
    );
  }
}

// ============================================================
// LOADING
// ============================================================

class _LoadingWidget
    extends StatelessWidget {
  final bool isCollapsed;

  final Color surfaceColor;

  final Color primaryColor;

  const _LoadingWidget({
    required this.isCollapsed,
    required this.surfaceColor,
    required this.primaryColor,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      EdgeInsets.all(12.w),
      decoration:
      BoxDecoration(
        color: surfaceColor,
        borderRadius:
        BorderRadius.circular(12.r),
      ),
      child: Center(
        child: SizedBox(
          width: 20.w,
          height: 20.w,
          child:
          const CircularProgressIndicator(
            color:
            Color(0xFFFFC107),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// USER
// ============================================================

class _UserWidget
    extends StatelessWidget {
  final bool isCollapsed;

  final Color surfaceColor;

  final Color primaryColor;

  final String initial;

  final String displayName;

  final String role;

  final String email;

  const _UserWidget({
    required this.isCollapsed,
    required this.surfaceColor,
    required this.primaryColor,
    required this.initial,
    required this.displayName,
    required this.role,
    required this.email,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return InkWell(
      onTap: () =>
          _showUserMenu(context),
      borderRadius:
      BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration:
        const Duration(
          milliseconds: 200,
        ),
        padding: EdgeInsets.all(
          isCollapsed
              ? 4.w
              : 12.w,
        ),
        decoration:
        BoxDecoration(
          color: surfaceColor,
          borderRadius:
          BorderRadius.circular(
            12.r,
          ),
          border: Border.all(
            color: Colors.white
                .withValues(
              alpha: 0.03,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment:
          isCollapsed
              ? MainAxisAlignment
              .center
              : MainAxisAlignment
              .start,
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor:
              primaryColor,
              child: Text(
                initial,
                style:
                GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  const Color(
                    0xFF090D16,
                  ),
                ),
              ),
            ),

            if (!isCollapsed) ...[
              SizedBox(
                width: 10.w,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style:
                      GoogleFonts.manrope(
                        color:
                        Colors.white,
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w600,
                      ),
                      overflow:
                      TextOverflow
                          .ellipsis,
                    ),

                    Text(
                      email,
                      style:
                      GoogleFonts.manrope(
                        color:
                        Colors.white38,
                        fontSize: 10,
                      ),
                      overflow:
                      TextOverflow
                          .ellipsis,
                    ),

                    SizedBox(
                      height: 2.h,
                    ),

                    Text(
                      role,
                      style:
                      GoogleFonts.manrope(
                        color:
                        primaryColor,
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons
                    .keyboard_arrow_up,
                color:
                Colors.white38,
                size: 20.sp,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MENU UTILISATEUR
  // ============================================================

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
        required Color color,
        bool isDestructive = false,
      }) {
    return Material(
      color:
      Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(
          12.r,
        ),
        child: Padding(
          padding:
          EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 22.sp,
              ),

              SizedBox(
                width: 16.w,
              ),

              Expanded(
                child: Text(
                  label,
                  style:
                  GoogleFonts.manrope(
                    color: color,
                    fontSize: 15.sp,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ),

              Icon(
                Icons
                    .arrow_forward_ios_rounded,
                color:
                Colors.white24,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MENU USER
  // ============================================================

  void _showUserMenu(
      BuildContext context,
      ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel:
      'Menu utilisateur',
      barrierColor:
      Colors.black.withValues(
        alpha: 0.4,
      ),
      transitionDuration:
      const Duration(
        milliseconds: 240,
      ),
      pageBuilder: (
          context,
          animation,
          secondaryAnimation,
          ) {
        return Align(
          alignment:
          Alignment.bottomLeft,
          child: Container(
            margin:
            EdgeInsets.only(
              left: 16.w,
              bottom: 85.h,
            ),
            width: 270.w,
            child: Material(
              color:
              Colors.transparent,
              child: FadeTransition(
                opacity: animation,
                child:
                SlideTransition(
                  position:
                  Tween<Offset>(
                    begin:
                    const Offset(
                      -0.06,
                      0,
                    ),
                    end:
                    Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent:
                      animation,
                      curve:
                      Curves
                          .easeOutCubic,
                    ),
                  ),
                  child:
                  Container(
                    padding:
                    EdgeInsets.all(
                      16.w,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFF111622,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        16.r,
                      ),
                      border:
                      Border.all(
                        color: Colors
                            .white
                            .withValues(
                          alpha: 0.06,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .black
                              .withValues(
                            alpha:
                            0.5,
                          ),
                          blurRadius:
                          20,
                          offset:
                          const Offset(
                            4,
                            4,
                          ),
                        ),
                      ],
                    ),
                    child:
                    Column(
                      mainAxisSize:
                      MainAxisSize
                          .min,
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Container(
                          decoration:
                          BoxDecoration(
                            color:
                            const Color(
                              0xFF0A0F1E,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              12.r,
                            ),
                          ),
                          child:
                          Column(
                            children: [
                              _buildMenuItem(
                                context,
                                icon:
                                Icons
                                    .person_outline_rounded,
                                label:
                                'Mon compte',
                                onTap:
                                    () => Navigator
                                    .pop(
                                  context,
                                ),
                                color:
                                Colors
                                    .white70,
                              ),

                              Divider(
                                color: Colors
                                    .white
                                    .withValues(
                                  alpha:
                                  0.05,
                                ),
                                height: 1,
                              ),

                              _buildMenuItem(
                                context,
                                icon:
                                Icons
                                    .settings_outlined,
                                label:
                                'Paramètres',
                                onTap:
                                    () => Navigator
                                    .pop(
                                  context,
                                ),
                                color:
                                Colors
                                    .white70,
                              ),

                              Divider(
                                color: Colors
                                    .white
                                    .withValues(
                                  alpha:
                                  0.05,
                                ),
                                height: 1,
                              ),

                              _buildMenuItem(
                                context,
                                icon:
                                Icons
                                    .help_outline_rounded,
                                label:
                                'Aide et support',
                                onTap:
                                    () => Navigator
                                    .pop(
                                  context,
                                ),
                                color:
                                Colors
                                    .white70,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: 12.h,
                        ),

                        Container(
                          decoration:
                          BoxDecoration(
                            color:
                            const Color(
                              0xFF0A0F1E,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              12.r,
                            ),
                          ),
                          child:
                          _buildMenuItem(
                            context,
                            icon:
                            Icons
                                .logout_rounded,
                            label:
                            'Déconnexion',
                            onTap: () {
                              Navigator
                                  .pop(
                                context,
                              );

                              _showLogoutDialog(
                                context,
                              );
                            },
                            color:
                            const Color(
                              0xFFEF4444,
                            ),
                            isDestructive:
                            true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DIALOG DÉCONNEXION
  // ============================================================

  void _showLogoutDialog(
      BuildContext context,
      ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel:
      'Déconnexion',
      barrierColor:
      Colors.black.withValues(
        alpha: 0.4,
      ),
      transitionDuration:
      const Duration(
        milliseconds: 240,
      ),
      pageBuilder: (
          context,
          animation,
          secondaryAnimation,
          ) {
        return Align(
          alignment:
          Alignment.bottomLeft,
          child: Container(
            margin:
            EdgeInsets.only(
              left: 16.w,
              bottom: 85.h,
            ),
            width: 270.w,
            child: Material(
              color:
              Colors.transparent,
              child: FadeTransition(
                opacity: animation,
                child:
                SlideTransition(
                  position:
                  Tween<Offset>(
                    begin:
                    const Offset(
                      -0.06,
                      0,
                    ),
                    end:
                    Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent:
                      animation,
                      curve:
                      Curves
                          .easeOutCubic,
                    ),
                  ),
                  child:
                  Container(
                    padding:
                    EdgeInsets.all(
                      20.w,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFF111622,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        16.r,
                      ),
                      border:
                      Border.all(
                        color: Colors
                            .white
                            .withValues(
                          alpha: 0.06,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .black
                              .withValues(
                            alpha:
                            0.5,
                          ),
                          blurRadius:
                          20,
                          offset:
                          const Offset(
                            4,
                            4,
                          ),
                        ),
                      ],
                    ),
                    child:
                    Column(
                      mainAxisSize:
                      MainAxisSize
                          .min,
                      children: [
                        Container(
                          padding:
                          EdgeInsets.all(
                            12.w,
                          ),
                          decoration:
                          BoxDecoration(
                            color: const Color(
                              0xFFEF4444,
                            ).withValues(
                              alpha:
                              0.1,
                            ),
                            shape:
                            BoxShape
                                .circle,
                          ),
                          child: Icon(
                            Icons
                                .logout_rounded,
                            color:
                            const Color(
                              0xFFEF4444,
                            ),
                            size: 26.sp,
                          ),
                        ),

                        SizedBox(
                          height: 14.h,
                        ),

                        Text(
                          'Déconnexion',
                          style:
                          GoogleFonts.manrope(
                            color:
                            Colors.white,
                            fontSize:
                            18.sp,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        SizedBox(
                          height: 8.h,
                        ),

                        Text(
                          'Êtes-vous sûr de vouloir vous déconnecter ?',
                          style:
                          GoogleFonts.manrope(
                            color:
                            Colors.white54,
                            fontSize:
                            13.sp,
                          ),
                          textAlign:
                          TextAlign
                              .center,
                        ),

                        SizedBox(
                          height: 20.h,
                        ),

                        Row(
                          children: [
                            Expanded(
                              child:
                              OutlinedButton(
                                onPressed:
                                    () => Navigator
                                    .pop(
                                  context,
                                ),
                                style:
                                OutlinedButton
                                    .styleFrom(
                                  side:
                                  BorderSide(
                                    color: Colors
                                        .white
                                        .withValues(
                                      alpha:
                                      0.08,
                                    ),
                                  ),
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      10.r,
                                    ),
                                  ),
                                  padding:
                                  EdgeInsets
                                      .symmetric(
                                    vertical:
                                    12.h,
                                  ),
                                ),
                                child:
                                Text(
                                  'Annuler',
                                  style:
                                  GoogleFonts.manrope(
                                    color:
                                    Colors.white54,
                                    fontSize:
                                    13.sp,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 10.w,
                            ),

                            Expanded(
                              child:
                              ElevatedButton(
                                onPressed:
                                    () {
                                  Navigator
                                      .pop(
                                    context,
                                  );

                                  _logout(
                                    context,
                                  );
                                },
                                style:
                                ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                  const Color(
                                    0xFFEF4444,
                                  ),
                                  foregroundColor:
                                  Colors.white,
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      10.r,
                                    ),
                                  ),
                                  padding:
                                  EdgeInsets
                                      .symmetric(
                                    vertical:
                                    12.h,
                                  ),
                                ),
                                child:
                                Text(
                                  'Quitter',
                                  style:
                                  GoogleFonts.manrope(
                                    fontSize:
                                    13.sp,
                                    fontWeight:
                                    FontWeight.w600,
                                    color:
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void _logout(
      BuildContext context,
      ) {
    final userProvider =
    Provider.of<UserProvider>(
      context,
      listen: false,
    );

    userProvider.logout();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          'Déconnecté avec succès',
          style:
          GoogleFonts.manrope(
            fontSize: 14.sp,
          ),
        ),
        backgroundColor:
        const Color(0xFF10B981),
        behavior:
        SnackBarBehavior.floating,
        margin:
        EdgeInsets.all(16.w),
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }
}