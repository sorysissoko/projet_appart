
import 'auth_service.dart';
import 'auth_service_wrapper.dart';
import 'backend_service.dart';
import 'database_service.dart';
import 'date_service.dart';
import 'navigation_service.dart';

class ServiceLocator {
  ServiceLocator._();


  // SERVICES
  static AuthService? _auth;
  static AuthServiceWrapper? _authWrapper;
  static BackendService? _backend;
  static DatabaseService? _database;
  static DateService? _date;
  static NavigationService? _navigation;


  // AUTH
  static AuthService get auth {
    return _auth ??= AuthService();
  }

  static AuthServiceWrapper get authWrapper {
    return _authWrapper ??= AuthServiceWrapper();
  }


  // BACKEND
  static BackendService get backend {
    return _backend ??= BackendService();
  }


  // DATABASE
  static DatabaseService get database {
    return _database ??= DatabaseService();
  }


  // DATE
  static DateService get date {
    return _date ??= DateService();
  }

  // NAVIGATION
  static NavigationService get navigation {
    return _navigation ??= NavigationService();
  }


  // INITIALISATION
  static void initialize() {
    _auth ??= AuthService();
    _backend ??= BackendService();
    _database ??= DatabaseService();
    _date ??= DateService();
    _navigation ??= NavigationService();
    _authWrapper ??= AuthServiceWrapper();
  }


  // RESET
  static void reset() {
    _auth = null;
    _authWrapper = null;
    _backend = null;
    _database = null;
    _date = null;
    _navigation = null;
  }
}