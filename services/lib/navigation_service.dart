// lib/service/navigation_service.dart

import 'package:flutter/material.dart';

class NavigationService {

  // SINGLETON
  static final NavigationService _instance = NavigationService._internal();

  factory NavigationService() => _instance;

  NavigationService._internal();

  // ROUTES COMMUNES

  static const String loginRoute = '/connexion';

  // ROUTES LOCATAIRE
  static const String tenantRoute = '/tenant-home';

  // ROUTES PROPRIÉTAIRE
  //Dashboard propriétaire
  static const String ownerRoute = '/owner-dashboard';

  // ROUTES ADMIN
// Dashboard administrateur
  static const String adminRoute = '/admin-dashboard';

  // NAVIGATOR GLOBAL
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState? get navigator => navigatorKey.currentState;

  bool get isNavigatorReady => navigatorKey.currentState != null;

  // PUSH
  Future<void> pushNamed(String routeName) async {
    final nav = navigator;

    if (nav == null) {
      debugPrint('Navigator indisponible pour : $routeName');
      return;
    }

    await nav.pushNamed(routeName);
  }


  // PUSH AVEC ARGUMENTS
  Future<void> pushNamedWithArguments(
      String routeName, {
        Object? arguments,
      }) async {
    final nav = navigator;

    if (nav == null) {
      debugPrint('Navigator indisponible pour : $routeName');
      return;
    }

    await nav.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  // PUSH REPLACEMENT
  Future<void> pushReplacement(String routeName) async {
    final nav = navigator;

    if (nav == null) {
      debugPrint('Navigator indisponible pour : $routeName');
      return;
    }

    await nav.pushReplacementNamed(routeName);
  }

  // PUSH REPLACEMENT AVEC ARGUMENTS
  Future<void> pushReplacementWithArguments(
      String routeName, {
        Object? arguments,
      }) async {
    final nav = navigator;

    if (nav == null) {
      debugPrint('Navigator indisponible pour : $routeName');
      return;
    }

    await nav.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }


  // REMPLACER VIDER TOUT L'HISTORIQUE
    Future<void> pushReplacementAndClearStack(String routeName) async {
    final nav = navigator;

    if (nav == null) {
      debugPrint('Navigator indisponible pour : $routeName');
      return;
    }

    await nav.pushNamedAndRemoveUntil(
      routeName,
          (route) => false,
    );
  }


  // REMPLACER VIDER ARGUMENTS
  Future<void> pushReplacementAndClearStackWithArguments(
      String routeName, {
        Object? arguments,
      }) async {
    final nav = navigator;

    if (nav == null) {
      debugPrint('Navigator indisponible pour : $routeName');
      return;
    }

    await nav.pushNamedAndRemoveUntil(
      routeName,
          (route) => false,
      arguments: arguments,
    );
  }

  // CONNEXION
  Future<void> goToLogin() async {
    await pushReplacementAndClearStack(loginRoute);
  }

  // ESPACE LOCATAIRE
  Future<void> goToTenant() async {
    await pushReplacementAndClearStack(tenantRoute);
  }

  // ESPACE PROPRIÉTAIRE
  Future<void> goToOwner() async {
    await pushReplacementAndClearStack(ownerRoute);
  }

  // ESPACE ADMIN
  Future<void> goToAdmin() async {
    await pushReplacementAndClearStack(adminRoute);
  }


  // ESPACE LOCATAIRE AVEC ARGUMENTS
  Future<void> goToTenantWithArguments(Object? arguments) async {
    await pushReplacementAndClearStackWithArguments(
      tenantRoute,
      arguments: arguments,
    );
  }


  // ESPACE PROPRIÉTAIRE AVEC ARGUMENTS
  Future<void> goToOwnerWithArguments(Object? arguments) async {
    await pushReplacementAndClearStackWithArguments(
      ownerRoute,
      arguments: arguments,
    );
  }


  // ESPACE ADMIN AVEC ARGUMENTS
  Future<void> goToAdminWithArguments(Object? arguments) async {
    await pushReplacementAndClearStackWithArguments(
      adminRoute,
      arguments: arguments,
    );
  }


  // RETOUR
  void pop<T extends Object?>([T? result]) {
    final nav = navigator;

    if (nav == null) {
      debugPrint('Navigator indisponible.');
      return;
    }

    if (nav.canPop()) {
      nav.pop(result);
    }
  }

  bool canPop() {
    return navigator?.canPop() ?? false;
  }


  // POP JUSQU'À UNE ROUTE
  void popUntil(String routeName) {
    final nav = navigator;

    if (nav == null) {
      debugPrint('Navigator indisponible.');
      return;
    }

    nav.popUntil(ModalRoute.withName(routeName));
  }


  // RETOUR À L'ACCUEIL LOCATAIRE
  Future<void> goToTenantAndClearStack() async {
    await pushReplacementAndClearStack(tenantRoute);
  }

  // RETOUR À L'ACCUEIL PROPRIÉTAIRE
  Future<void> goToOwnerAndClearStack() async {
    await pushReplacementAndClearStack(ownerRoute);
  }


  // RETOUR AU DASHBOARD ADMIN
  Future<void> goToAdminAndClearStack() async {
    await pushReplacementAndClearStack(adminRoute);
  }

  // VÉRIFICATION ROUTE COURANTE
  bool isCurrentRoute(String routeName) {
    final context = navigator?.context;

    if (context == null) {
      return false;
    }

    final route = ModalRoute.of(context);

    return route?.settings.name == routeName;
  }
}