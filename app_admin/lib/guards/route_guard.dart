// lib/guards/route_guard.dart

import 'package:flutter/material.dart';

import 'package:service/auth_service_wrapper.dart';
import 'package:service/navigation_service.dart';
import 'package:service/security_service.dart';
import 'package:service/service_locator.dart';

class RouteGuard {

  // SERVICES
  static AuthServiceWrapper get _auth =>
      ServiceLocator.authWrapper;

  static NavigationService get _navigation =>
      ServiceLocator.navigation;


  // ROUTES
  static const String loginRoute = '/connexion';
  static const String dashboardRoute = '/admin-dashboard';

  // AUTHENTIFICATION
  static Future<bool> isAuthenticated() async {
    return _auth.isAuthenticated;
  }

  // RÔLE ACTUEL
  static Future<String?> getCurrentRole() async {
    if (!_auth.isAuthenticated) {
      return null;
    }

    try {
      final role = await _auth.getUserRole();

      if (role == null) {
        debugPrint(
          'RouteGuard ADMIN : aucun rôle trouvé.',
        );

        return null;
      }

      final normalizedRole =
      SecurityService.normalizeRole(role);

      if (!SecurityService.isValidRole(
        normalizedRole,
      )) {
        debugPrint(
          'RouteGuard ADMIN : rôle invalide : '
              '$normalizedRole',
        );

        return null;
      }

      return normalizedRole;
    } catch (e) {
      debugPrint(
        'RouteGuard ADMIN : erreur récupération rôle : $e',
      );

      return null;
    }
  }

  // COMPATIBILITÉ
  static Future<String?> getCurrentUserRole() async {
    return getCurrentRole();
  }


  // AUTORISATION ADMIN
  static Future<bool> isAdmin() async {
    final role = await getCurrentRole();

    return role == SecurityService.roleAdmin ||
        role == SecurityService.roleSuperAdmin;
  }


  // SESSION
  static Future<bool> isSessionValid() async {
    try {
      return await _auth.checkSession();
    } catch (e) {
      debugPrint(
        'RouteGuard ADMIN : erreur vérification session : $e',
      );

      return false;
    }
  }


  // DASHBOARD
  static String? getDashboardForRole(
      String? role,
      ) {
    if (role == null) {
      return null;
    }

    final normalizedRole =
    SecurityService.normalizeRole(role);

    if (normalizedRole == SecurityService.roleAdmin ||
        normalizedRole == SecurityService.roleSuperAdmin) {
      return dashboardRoute;
    }

    return null;
  }

  // ============================================================
  // CHECK ACCESS
  // ============================================================

  /// Vérifie l'accès à une route de l'APP ADMIN.
  ///
  /// Si requireAuth = true :
  ///     l'utilisateur doit être connecté.
  ///
  /// Si requireAdmin = true :
  ///     l'utilisateur doit être :
  ///     - admin
  ///     - super_admin
  static Future<bool> checkAccess({
    required BuildContext context,
    bool requireAuth = true,
    bool requireAdmin = false,
    bool showSnackBar = true,
  }) async {
    // ==========================================================
    // 1. AUTHENTIFICATION
    // ==========================================================

    if (requireAuth) {
      final authenticated =
      await isAuthenticated();

      if (!authenticated) {
        _redirectToLogin(
          context,
          showSnackBar: showSnackBar,
        );

        return false;
      }

      // --------------------------------------------------------
      // SESSION
      // --------------------------------------------------------

      final sessionValid =
      await isSessionValid();

      if (!sessionValid) {
        _redirectToLogin(
          context,
          showSnackBar: showSnackBar,
        );

        return false;
      }
    }

    // ==========================================================
    // 2. ROUTE AUTHENTIFIÉE SANS RESTRICTION ADMIN
    // ==========================================================

    if (!requireAdmin) {
      return true;
    }

    // ==========================================================
    // 3. RÉCUPÉRATION DU RÔLE
    // ==========================================================

    final role = await getCurrentRole();

    debugPrint(
      '🔐 RouteGuard ADMIN - rôle actuel : $role',
    );

    // ==========================================================
    // 4. VALIDATION DU RÔLE
    // ==========================================================

    if (!SecurityService.isValidRole(role)) {
      debugPrint(
        '❌ RouteGuard ADMIN - rôle invalide : $role',
      );

      _accessDenied(
        context,
        'Rôle utilisateur invalide.',
        loginRoute,
        showSnackBar,
      );

      return false;
    }

    // ==========================================================
    // 5. VÉRIFICATION ADMIN
    // ==========================================================

    if (requireAdmin) {
      final allowed = isAdminRole(role);

      debugPrint(
        '🔐 Accès APP ADMIN : $allowed',
      );

      if (!allowed) {
        _accessDenied(
          context,
          'Accès refusé : droits administrateur requis.',
          loginRoute,
          showSnackBar,
        );

        return false;
      }

      return true;
    }

    return true;
  }

  // ============================================================
  // VÉRIFICATION RÔLE ADMIN
  // ============================================================

  static bool isAdminRole(String? role) {
    if (role == null) {
      return false;
    }

    final normalizedRole =
    SecurityService.normalizeRole(role);

    return normalizedRole == SecurityService.roleAdmin ||
        normalizedRole == SecurityService.roleSuperAdmin;
  }

  // ============================================================
  // HAS ROLE
  // ============================================================

  /// Vérifie le rôle exact.
  ///
  /// Exemple :
  ///
  /// hasRole('admin')
  /// hasRole('super_admin')
  static Future<bool> hasRole(
      String targetRole,
      ) async {
    final role = await getCurrentRole();

    if (!isAdminRole(role)) {
      return false;
    }

    final normalizedTarget =
    SecurityService.normalizeRole(targetRole);

    return role == normalizedTarget;
  }

  // ============================================================
  // CAN ACCESS ADMIN
  // ============================================================

  /// Vérifie si l'utilisateur actuel peut accéder
  /// à l'APP ADMIN.
  static Future<bool> canAccessAdmin() async {
    final role = await getCurrentRole();

    return isAdminRole(role);
  }

  // ============================================================
  // REDIRECTION CONNEXION
  // ============================================================

  static void _redirectToLogin(
      BuildContext context, {
        bool showSnackBar = true,
      }) {
    if (!context.mounted) {
      return;
    }

    if (showSnackBar) {
      ScaffoldMessenger.of(context)
          .removeCurrentSnackBar();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Votre session a expiré. '
                'Veuillez vous reconnecter.',
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    _navigation.pushReplacementAndClearStack(
      loginRoute,
    );
  }

  // ============================================================
  // ACCÈS REFUSÉ
  // ============================================================

  static void _accessDenied(
      BuildContext context,
      String message,
      String fallbackRoute,
      bool showSnackBar,
      ) {
    if (!context.mounted) {
      return;
    }

    if (showSnackBar) {
      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    debugPrint(
      '🚫 RouteGuard ADMIN : accès refusé. '
          'Redirection vers : $fallbackRoute',
    );

    _navigation.pushReplacementAndClearStack(
      fallbackRoute,
    );
  }

  // ============================================================
  // REDIRECTION DASHBOARD
  // ============================================================

  static Future<void> redirectToRoleDashboard(
      BuildContext context,
      ) async {
    final role = await getCurrentRole();

    if (!context.mounted) {
      return;
    }

    if (!isAdminRole(role)) {
      _redirectToLogin(
        context,
        showSnackBar: true,
      );

      return;
    }

    debugPrint(
      '🔀 RouteGuard ADMIN : '
          'rôle [$role] → [$dashboardRoute]',
    );

    await _navigation.pushReplacementAndClearStack(
      dashboardRoute,
    );
  }
}