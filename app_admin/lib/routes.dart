import 'package:admin/presentation/screens/notifications/notifications_page.dart';
import 'package:admin/presentation/screens/properties/owner_list_screen.dart';
import 'package:flutter/material.dart';

import 'package:admin/presentation/page_acceuille/page_acceuille.dart';
import 'package:admin/presentation/screens/auth/login_screen.dart';
import 'package:admin/presentation/screens/auth/register_screen.dart';
import 'package:admin/presentation/screens/bookings/reservation_list_screen.dart';
import 'package:admin/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:admin/presentation/screens/properties/locataire_list_screen.dart';
import 'package:admin/presentation/screens/properties/property_list_screen.dart';

import 'package:admin/guards/route_guard.dart';
import 'package:google_fonts/google_fonts.dart';

class AppRoutes {
  // ============================================================
  // ROUTES PUBLIQUES
  // ============================================================

  static const String home = '/';
  static const String connexion = '/connexion';
  static const String register = '/register';

  // ============================================================
  // ROUTES PROTÉGÉES ADMIN
  // ============================================================

  static const String dashboard = '/admin-dashboard';
  static const String users = '/users';
  static const String owners = '/owners';
  static const String reservations = '/reservations';
  static const String settings = '/settings';
  static const String messages = '/messages';
  static const String photoAppart = '/photo_appart';
  static const String notification = '/notification';
  static const String profile = '/profile';
  static const String transactions = '/transactions';
  static const String analytics = '/analytics';

  // ============================================================
  // VILLES & TYPES
  // ============================================================

  static const List<String> cities = [
    'Bamako',
    'Kayes',
    'Koulikoro',
    'Segou',
    'Sikasso',
  ];

  static const Map<String, String> propertyTypes = {
    'Appart': 'Apparts',
    'Villa': 'Villas',
    'Studio': 'Studios',
  };

  // ============================================================
  // NORMALISATION
  // ============================================================

  static String _normalizeCity(String city) {
    return city
        .trim()
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(' ', '_');
  }

  static String _normalizePropertyType(String type) {
    return type
        .trim()
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(' ', '_');
  }

  // ============================================================
  // GÉNÉRATION DES ROUTES DES PROPRIÉTÉS
  // ============================================================

  static Map<String, _RouteConfig> _generatePropertyRoutes() {
    final Map<String, _RouteConfig> routes = {};

    for (final city in cities) {
      for (final entry in propertyTypes.entries) {
        final String type = entry.key;
        final String label = entry.value;

        final String routeName =
            '/list_${_normalizePropertyType(type)}_${_normalizeCity(city)}';

        routes[routeName] = _RouteConfig(
          builder: (context, args) {
            debugPrint('🏠 Ouverture $routeName avec args = $args');

            return PropertyListScreen(
              city: city,
              propertyType: type,
              title: '$label - $city',
              initialAppartementId: args?['appartementId']?.toString(),
              initialResidenceId: args?['initialResidenceId']?.toString(),
              focusResidenceId: args?['focusResidenceId']?.toString(),
            );
          },
          requireAuth: true,
          requireAdmin: true,
        );
      }
    }

    return routes;
  }

  // ============================================================
  // GÉNÉRATEUR PRINCIPAL
  // ============================================================

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? home;
    final args = settings.arguments as Map<String, dynamic>?;

    debugPrint(
      '🔵 Navigation vers : $routeName | args = $args',
    );

    // ==========================================================
    // ROUTES PUBLIQUES
    // ==========================================================

    switch (routeName) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const Home1Page(),
          settings: settings,
        );

      case connexion:
        return MaterialPageRoute(
          builder: (_) => const ConnexionWidget(),
          settings: settings,
        );
    }

    // ==========================================================
    // ROUTES PROTÉGÉES
    // ==========================================================

    final Map<String, _RouteConfig> protectedRoutes = {
      // --------------------------------------------------------
      // REGISTER
      // --------------------------------------------------------
      register: _RouteConfig(
        builder: (_, __) => const RegisterWidget(),
        requireAuth: true,
        requireAdmin: true,
      ),

      // --------------------------------------------------------
      // DASHBOARD
      // --------------------------------------------------------
      dashboard: _RouteConfig(
        builder: (_, __) => const DashboardScreen(),
        requireAuth: true,
        requireAdmin: true,
      ),

      // --------------------------------------------------------
      // UTILISATEURS (LOCATAIRES)
      // --------------------------------------------------------
      users: _RouteConfig(
        builder: (context, args) {
          debugPrint('👤 Ouverture /users avec args = $args');

          return LocataireListScreen(
            initialUserId: args?['userId']?.toString(),
            initialDocumentId: args?['documentId']?.toString(),
          );
        },
        requireAuth: true,
        requireAdmin: true,
      ),

      // --------------------------------------------------------
      // PROPRIÉTAIRES
      // --------------------------------------------------------
      owners: _RouteConfig(
        builder: (context, args) {
          debugPrint('🏢 Ouverture /owners avec args = $args');

          return OwnerListScreen(
            initialUserId: args?['userId']?.toString(),
            initialDocumentId: args?['documentId']?.toString(),
          );
        },
        requireAuth: true,
        requireAdmin: true,
      ),

      // --------------------------------------------------------
      // RÉSERVATIONS
      // --------------------------------------------------------
      reservations: _RouteConfig(
        builder: (_, __) => const ReservationListScreen(),
        requireAuth: true,
        requireAdmin: true,
      ),

      // --------------------------------------------------------
      // MESSAGES
      // --------------------------------------------------------
      messages: _RouteConfig(
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Messages')),
        ),
        requireAuth: true,
        requireAdmin: true,
      ),

      // --------------------------------------------------------
      // PHOTOS APPARTEMENTS
      // --------------------------------------------------------
      photoAppart: _RouteConfig(
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Photos Appartements')),
        ),
        requireAuth: true,
        requireAdmin: true,
      ),

      // --------------------------------------------------------
      // NOTIFICATIONS
      // --------------------------------------------------------
      notification: _RouteConfig(
        builder: (_, __) => const NotificationsPage(),
        requireAuth: true,
        requireAdmin: true,
      ),

      // --------------------------------------------------------
      // PROFIL
      // --------------------------------------------------------
      profile: _RouteConfig(
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Profil')),
        ),
        requireAuth: true,
        requireAdmin: true,
      ),

      // --------------------------------------------------------
      // TRANSACTIONS
      // --------------------------------------------------------
      transactions: _RouteConfig(
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Transactions')),
        ),
        requireAuth: true,
        requireAdmin: true,
      ),

      // --------------------------------------------------------
      // ANALYTICS
      // --------------------------------------------------------
      analytics: _RouteConfig(
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Analytiques')),
        ),
        requireAuth: true,
        requireAdmin: true,
      ),
    };

    // ==========================================================
    // AJOUT DES ROUTES DYNAMIQUES DES PROPRIÉTÉS
    // ==========================================================

    protectedRoutes.addAll(_generatePropertyRoutes());

    // ==========================================================
    // RECHERCHE DE LA CONFIG
    // ==========================================================

    final _RouteConfig? config = protectedRoutes[routeName];

    // ==========================================================
    // ROUTE INCONNUE
    // ==========================================================

    if (config == null) {
      debugPrint('❌ Route non trouvée : $routeName');

      return MaterialPageRoute(
        builder: (_) => _UnknownRoutePage(routeName: routeName),
        settings: settings,
      );
    }

    // ==========================================================
    // CONSTRUCTION ROUTE SÉCURISÉE
    // ==========================================================

    return _buildSecuredRoute(
      settings: settings,
      config: config,
      args: args,
    );
  }

  // ============================================================
  // ROUTE SÉCURISÉE
  // ============================================================

  static Route<dynamic> _buildSecuredRoute({
    required RouteSettings settings,
    required _RouteConfig config,
    Map<String, dynamic>? args,
  }) {
    return MaterialPageRoute(
      builder: (context) {
        return _RouteGuardWrapper(
          builder: (ctx) => config.builder(ctx, args),
          requireAuth: config.requireAuth,
          requireAdmin: config.requireAdmin,
          settings: settings,
        );
      },
      settings: settings,
    );
  }
}

// ============================================================
// CONFIGURATION D'UNE ROUTE
// ============================================================

class _RouteConfig {
  /// Le builder reçoit le context ET les arguments.
  final Widget Function(BuildContext context, Map<String, dynamic>? args)
  builder;

  final bool requireAuth;
  final bool requireAdmin;

  const _RouteConfig({
    required this.builder,
    this.requireAuth = true,
    this.requireAdmin = false,
  });
}

// ============================================================
// PAGE ROUTE INCONNUE
// ============================================================

class _UnknownRoutePage extends StatelessWidget {
  final String? routeName;

  const _UnknownRoutePage({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                'Page introuvable',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                routeName ?? 'Route inconnue',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.dashboard,
                        (_) => false,
                  );
                },
                icon: const Icon(Icons.dashboard_rounded),
                label: const Text('Retour au tableau de bord'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// WRAPPER DE SÉCURITÉ
// ============================================================

class _RouteGuardWrapper extends StatefulWidget {
  final WidgetBuilder builder;
  final bool requireAuth;
  final bool requireAdmin;
  final RouteSettings settings;

  const _RouteGuardWrapper({
    required this.builder,
    required this.requireAuth,
    required this.requireAdmin,
    required this.settings,
  });

  @override
  State<_RouteGuardWrapper> createState() => _RouteGuardWrapperState();
}

class _RouteGuardWrapperState extends State<_RouteGuardWrapper> {
  bool _isChecking = true;
  String? _redirectRoute;
  bool _redirecting = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    try {
      final bool access = await RouteGuard.checkAccess(
        context: context,
        requireAuth: widget.requireAuth,
        requireAdmin: widget.requireAdmin,
        showSnackBar: true,
      );

      if (!mounted) return;

      if (!access) {
        setState(() {
          _redirectRoute =
          widget.requireAuth ? AppRoutes.connexion : AppRoutes.home;
          _isChecking = false;
        });
        return;
      }

      setState(() => _isChecking = false);
    } catch (e) {
      debugPrint(
        '❌ Erreur vérification route ${widget.settings.name}: $e',
      );

      if (!mounted) return;

      setState(() {
        _redirectRoute = AppRoutes.connexion;
        _isChecking = false;
      });
    }
  }

  void _performRedirect() {
    if (_redirecting) return;
    _redirecting = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, _redirectRoute!);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const _RouteLoadingPage();
    }

    if (_redirectRoute != null) {
      _performRedirect();
      return const _RouteLoadingPage();
    }

    return widget.builder(context);
  }
}

// ============================================================
// PAGE DE CHARGEMENT
// ============================================================

class _RouteLoadingPage extends StatelessWidget {
  const _RouteLoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF090D16),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFFC107),
          strokeWidth: 2,
        ),
      ),
    );
  }
}