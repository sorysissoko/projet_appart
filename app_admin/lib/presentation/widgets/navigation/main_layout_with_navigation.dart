import 'dart:async';

import 'package:admin/presentation/screens/notifications/notification_service.dart';
import 'package:admin/presentation/widgets/navigation/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../responsive.dart';
import '../../../routes.dart';
import '../../providers/user_provider.dart';

class MainLayoutWithNavigation
    extends StatefulWidget {
  final String initialRoute;

  final Map<String, WidgetBuilder> routes;

  final Map<String, String> routeTitles;

  const MainLayoutWithNavigation({
    super.key,
    required this.initialRoute,
    required this.routes,
    required this.routeTitles,
  });

  @override
  State<MainLayoutWithNavigation>
  createState() =>
      _MainLayoutWithNavigationState();
}

class _MainLayoutWithNavigationState
    extends State<
        MainLayoutWithNavigation> {
  // ============================================================
  // ROUTE
  // ============================================================

  late String _currentRoute;

  // ============================================================
  // DRAWER
  // ============================================================

  final GlobalKey<ScaffoldState>
  _scaffoldKey =
  GlobalKey<ScaffoldState>();

  final ValueNotifier<bool>
  _isMenuCollapsed =
  ValueNotifier<bool>(false);

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  final NotificationService
  _notificationService =
  NotificationService();

  StreamSubscription<
      NotificationRealtimeEvent>?
  _notificationSubscription;

  int _unreadNotificationCount = 0;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _currentRoute =
        widget.initialRoute;

    // Charger le nombre de notifications
    _loadUnreadNotificationCount();

    // Démarrer Realtime
    _notificationService
        .startRealtime();

    // Écouter les événements
    _notificationSubscription =
        _notificationService.events.listen(
          _handleNotificationEvent,
        );
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
        _unreadNotificationCount =
            count;
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

        case NotificationRealtimeType
            .inserted:
          if (event.newIsRead != true) {
            _unreadNotificationCount++;
          }

          break;

      // ------------------------------------------------------
      // UPDATE
      // ------------------------------------------------------

        case NotificationRealtimeType
            .updated:
          final oldRead =
              event.oldIsRead ?? false;

          final newRead =
              event.newIsRead ?? false;

          // Non lue -> lue
          if (!oldRead && newRead) {
            _unreadNotificationCount--;

            if (_unreadNotificationCount <
                0) {
              _unreadNotificationCount =
              0;
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

        case NotificationRealtimeType
            .deleted:
          if (event.oldIsRead == false) {
            _unreadNotificationCount--;

            if (_unreadNotificationCount <
                0) {
              _unreadNotificationCount =
              0;
            }
          }

          break;
      }
    });
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void navigateTo(
      String route,
      ) {
    if (widget.routes
        .containsKey(route)) {
      setState(() {
        _currentRoute = route;
      });

      // Fermer le drawer sur mobile
      if (Responsive.isMobile(
          context)) {
        if (_scaffoldKey
            .currentState
            ?.isDrawerOpen ==
            true) {
          Navigator.of(context).pop();
        }
      }

      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: const Text(
          '📌 Page en cours de développement',
        ),
        backgroundColor:
        const Color(0xFFFFC107),
        duration:
        const Duration(seconds: 2),
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
    final isDesktop =
    Responsive.isDesktop(
      context,
    );

    context.watch<UserProvider>();

    return Scaffold(
      key: _scaffoldKey,

      backgroundColor:
      const Color(0xFF090D16),

      // ========================================================
      // DRAWER MOBILE
      // ========================================================

      drawer: !isDesktop
          ? SideMenu(
        isCollapsed: false,
        onNavigate:
        navigateTo,
      )
          : null,

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child:
        ValueListenableBuilder<
            bool>(
          valueListenable:
          _isMenuCollapsed,

          builder: (
              context,
              isCollapsed,
              child,
              ) {
            return Row(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                // ------------------------------------------------
                // SIDEBAR DESKTOP
                // ------------------------------------------------

                if (isDesktop)
                  AnimatedContainer(
                    duration:
                    const Duration(
                      milliseconds: 200,
                    ),

                    width:
                    isCollapsed
                        ? 80.w
                        : 220.w,

                    child: SideMenu(
                      isCollapsed:
                      isCollapsed,
                      onNavigate:
                      navigateTo,
                    ),
                  ),

                // ------------------------------------------------
                // CONTENU
                // ------------------------------------------------

                Expanded(
                  child:
                  Column(
                    children: [
                      _buildAppBar(
                        isDesktop:
                        isDesktop,
                        isCollapsed:
                        isCollapsed,
                        onToggleMenu:
                            () {
                          _isMenuCollapsed
                              .value =
                          !_isMenuCollapsed
                              .value;
                        },
                      ),

                      Expanded(
                        child:
                        IndexedStack(
                          index:
                          _getPageIndex(
                            _currentRoute,
                          ),
                          children:
                          _getPages(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  Widget _buildAppBar({
    required bool isDesktop,
    required bool isCollapsed,
    required VoidCallback
    onToggleMenu,
  }) {
    final title =
        widget.routeTitles[
        _currentRoute] ??
            'DS Appart';

    return Container(
      padding:
      EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),

      decoration:
      BoxDecoration(
        color:
        const Color(0xFF090D16),
        border: Border(
          bottom: BorderSide(
            color: Colors.white
                .withValues(
              alpha: 0.05,
            ),
            width: 1,
          ),
        ),
      ),

      child: Row(
        children: [
          // ======================================================
          // MENU
          // ======================================================

          IconButton(
            tooltip:
            'Menu',

            icon: const Icon(
              Icons.menu,
              color:
              Colors.white,
              size: 22,
            ),

            onPressed: isDesktop
                ? onToggleMenu
                : () {
              _scaffoldKey
                  .currentState
                  ?.openDrawer();
            },

            padding:
            EdgeInsets.zero,

            constraints:
            const BoxConstraints(),
          ),

          SizedBox(
            width: 8.w,
          ),

          // ======================================================
          // TITRE
          // ======================================================

          Expanded(
            child: Text(
              title,

              style:
              GoogleFonts.manrope(
                color:
                Colors.white,
                fontSize:
                18.sp,
                fontWeight:
                FontWeight.bold,
              ),

              overflow:
              TextOverflow
                  .ellipsis,
            ),
          ),

          // ======================================================
          // NOTIFICATIONS
          // ======================================================

          Stack(
            clipBehavior:
            Clip.none,

            children: [
              IconButton(
                tooltip:
                'Notifications',

                icon:
                const Icon(
                  Icons
                      .notifications_none_rounded,
                  color:
                  Colors.white,
                  size: 22,
                ),

                onPressed: () {
                  navigateTo(
                    AppRoutes
                        .notification,
                  );
                },
              ),

              // Badge
              if (_unreadNotificationCount >
                  0)
                Positioned(
                  right: 5,
                  top: 2,

                  child:
                  Container(
                    constraints:
                    const BoxConstraints(
                      minWidth: 17,
                      minHeight: 17,
                    ),

                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 4,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      Colors.redAccent,

                      borderRadius:
                      BorderRadius
                          .circular(
                        20,
                      ),

                      border:
                      Border.all(
                        color:
                        const Color(
                          0xFF090D16,
                        ),
                        width: 2,
                      ),
                    ),

                    child:
                    Text(
                      _unreadNotificationCount >
                          99
                          ? '99+'
                          : _unreadNotificationCount
                          .toString(),

                      textAlign:
                      TextAlign
                          .center,

                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                        fontSize:
                        9,
                        fontWeight:
                        FontWeight
                            .bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(
            width: 4.w,
          ),

          // ======================================================
          // REFRESH
          // ======================================================

          IconButton(
            tooltip:
            'Actualiser',

            icon:
            const Icon(
              Icons.refresh_rounded,
              color:
              Color(0xFFFFC107),
              size: 20,
            ),

            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INDEX PAGE
  // ============================================================

  int _getPageIndex(
      String route,
      ) {
    final routes =
    widget.routes.keys.toList();

    final index =
    routes.indexOf(route);

    return index != -1
        ? index
        : 0;
  }

  // ============================================================
  // PAGES
  // ============================================================

  List<Widget> _getPages() {
    return widget.routes.values
        .map(
          (builder) =>
          builder(context),
    )
        .toList();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _notificationSubscription
        ?.cancel();

    _isMenuCollapsed.dispose();

    super.dispose();
  }
}