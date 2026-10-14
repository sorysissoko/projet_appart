import 'package:provider/provider.dart';
import '../presentation/controllers/menu_app_controller.dart';
import '../presentation/controllers/dashboard_controller.dart';

class DependencyInjection {
  static final DependencyInjection _instance = DependencyInjection._internal();
  factory DependencyInjection() => _instance;
  DependencyInjection._internal();

  // ─── CONTROLLERS ───
  late final MenuAppController _menuController;
  late final DashboardController _dashboardController;

  Future<void> init() async {
    // ✅ Utiliser ServiceLocator existant
    // Les services sont déjà initialisés dans main.dart

    // ✅ Créer les contrôleurs avec les services existants
    _menuController = MenuAppController();
    _dashboardController = DashboardController(
      // Les services sont déjà dans le contrôleur via ServiceLocator
    );
  }

  // ─── PROVIDERS ───
  List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider<MenuAppController>.value(
      value: _menuController,
    ),
    ChangeNotifierProvider<DashboardController>.value(
      value: _dashboardController,
    ),
  ];

  // ─── GETTERS ───
  MenuAppController get menuController => _menuController;
  DashboardController get dashboardController => _dashboardController;
}