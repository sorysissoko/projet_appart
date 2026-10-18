import 'package:flutter/foundation.dart';

import 'package:service/auth_service.dart';
import 'package:service/backend_service.dart';
import 'package:service/database_service.dart';
import 'package:service/service_locator.dart';

import '../../models/dashboard_data.dart';

class DashboardController extends ChangeNotifier {
  // ============================================================
  // SERVICES
  // ============================================================

  final AuthService _authService = ServiceLocator.auth;
  final BackendService _backendService = ServiceLocator.backend;
  final DatabaseService _databaseService = ServiceLocator.database;

  // ============================================================
  // ÉTAT
  // ============================================================

  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  DashboardData? _dashboardData;

  // ============================================================
  // CACHE
  // ============================================================

  DateTime _lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  static const Duration _cacheDuration = Duration(minutes: 5);

  bool _isCacheValid = false;

  // ============================================================
  // GETTERS
  // ============================================================

  bool get isLoading => _isLoading;

  bool get hasError => _hasError;

  String get errorMessage => _errorMessage;

  DashboardData? get dashboardData => _dashboardData;

  DashboardStats get stats =>
      _dashboardData?.stats ?? _emptyStats;

  List<RevenueDataPoint> get revenueData =>
      _dashboardData?.revenueData ?? const [];

  List<CityStats> get cities =>
      _dashboardData?.cities ?? const [];

  List<BookingData> get recentBookings =>
      _dashboardData?.recentBookings ?? const [];

  DateTime get lastUpdate =>
      _dashboardData?.lastUpdate ?? _lastUpdate;

  // ============================================================
  // DONNÉES VIDES
  // ============================================================

  static const DashboardStats _emptyStats = DashboardStats(
    totalAppartements: 0,
    totalVillas: 0,
    totalStudios: 0,
    totalReservations: 0,
    reservationsToday: 0,
    reservationsEnAttente: 0,
    reservationsConfirmees: 0,
    reservationsTerminees: 0,
    totalClients: 0,
    totalOwner: 0,
    totalService: 0,
  );



  // CHARGEMENT
  Future<void> loadDashboardData({
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return;

    // ----------------------------------------------------------
    // CACHE
    // ----------------------------------------------------------

    if (!forceRefresh &&
        _isCacheValid &&
        _dashboardData != null) {
      final age = DateTime.now().difference(_lastUpdate);

      if (age < _cacheDuration) {
        debugPrint('📊 Dashboard : utilisation du cache');
        return;
      }
    }

    _setLoading(true);
    _clearError();

    try {
      // --------------------------------------------------------
      // AUTHENTIFICATION
      // --------------------------------------------------------

      if (!_authService.isAuthenticated) {
        throw Exception(
          'Administrateur non connecté.',
        );
      }

      // --------------------------------------------------------
      // SESSION
      // --------------------------------------------------------

      await _authService.refreshSessionIfNeeded();

      // --------------------------------------------------------
      // VÉRIFICATION ADMIN
      // --------------------------------------------------------

      final isAdmin = await _backendService.isAdmin();

      if (!isAdmin) {
        throw Exception(
          'Accès refusé : droits administrateur requis.',
        );
      }

      // --------------------------------------------------------
      // CHARGEMENT
      // --------------------------------------------------------

      final data = await _fetchDashboardData();

      if (data == null) {
        throw Exception(
          'Impossible de récupérer les données du dashboard.',
        );
      }

      _dashboardData = data;
      _lastUpdate = DateTime.now();
      _isCacheValid = true;

      debugPrint('✅ Dashboard admin chargé');
    } catch (e, stackTrace) {
      _setError(
        e.toString().replaceFirst('Exception: ', ''),
      );

      if (kDebugMode) {
        debugPrint('❌ Dashboard : $e');
        debugPrint('$stackTrace');
      }
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // CHARGEMENT GLOBAL
  // ============================================================

  Future<DashboardData?> _fetchDashboardData() async {
    try {
      final results = await Future.wait<dynamic>([
        _fetchStats(),
        _fetchRevenueData(),
        _fetchCityStats(),
        _fetchRecentBookings(),
      ]);

      return DashboardData(
        stats: results[0] as DashboardStats,
        revenueData: results[1] as List<RevenueDataPoint>,
        cities: results[2] as List<CityStats>,
        recentBookings: results[3] as List<BookingData>,
        lastUpdate: DateTime.now(),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur dashboard : $e');

      if (kDebugMode) {
        debugPrint('$stackTrace');
      }

      return null;
    }
  }

  // ============================================================
  // STATISTIQUES
  // ============================================================

  Future<DashboardStats> _fetchStats() async {
    try {
      final appartements =
      await _databaseService.fetchAppartements();

      int totalAppartements = 0;
      int totalVillas = 0;
      int totalStudios = 0;

      for (final appartement in appartements) {
        final type = (appartement['type'] ?? '')
            .toString()
            .trim()
            .toLowerCase();

        if (type == 'appart' || type == 'apparts') {
          totalAppartements++;
        }

        if (type == 'villa' || type == 'villas') {
          totalVillas++;
        }

        if (type == 'studio' || type == 'studios') {
          totalAppartements++;
        }
      }

      final reservations = await _fetchAllReservations();

      int reservationsToday = 0;
      int reservationsEnAttente = 0;
      int reservationsConfirmees = 0;
      int reservationsTerminees = 0;

      final now = DateTime.now();

      final today = DateTime(
        now.year,
        now.month,
        now.day,
      );

      for (final reservation in reservations) {
        final statut = _normalizeStatus(
          reservation['statut'],
        );

        final dateDebut = reservation['date_debut'];

        if (dateDebut != null) {
          final date = DateTime.tryParse(
            dateDebut.toString(),
          );

          if (date != null) {
            final dateOnly = DateTime(
              date.year,
              date.month,
              date.day,
            );

            if (dateOnly == today) {
              reservationsToday++;
            }
          }
        }

        switch (statut) {
          case 'en_attente':
            reservationsEnAttente++;
            break;

          case 'confirmee':
          case 'confirme':
            reservationsConfirmees++;
            break;

          case 'terminee':
          case 'termine':
            reservationsTerminees++;
            break;
        }
      }

      final totalClients = await _fetchTotalClients();
      final totalOwner = await _fetchTotalOwner();
      final totalService = await _fetchTotalService();

      return DashboardStats(
        totalAppartements: totalAppartements,
        totalVillas: totalVillas,
        totalStudios: totalStudios,
        totalReservations: reservations.length,
        reservationsToday: reservationsToday,
        reservationsEnAttente: reservationsEnAttente,
        reservationsConfirmees: reservationsConfirmees,
        reservationsTerminees: reservationsTerminees,
        totalClients: totalClients,
        totalOwner: totalOwner,
        totalService:totalService,
      );
    } catch (e) {
      debugPrint('❌ Erreur statistiques : $e');

      return _emptyStats;
    }
  }

  // ============================================================
  // RÉSERVATIONS
  // ============================================================

  Future<List<Map<String, dynamic>>>
  _fetchAllReservations() async {
    try {
      final response = await _databaseService.supabase
          .from('reservations')
          .select('''
  *,
  appartement:appartements!reservations_appartement_id_fkey (
    id,
    titre,
    description,
    type,
    prix,
    prix_proprietaire,
    nbre_sejour,
    status,
    autres_equipements,
    frais_service,
    disponibilite_status,
    proprietaire_id,

    residence:residences!appartements_residence_id_fkey (
      id,
      nom,
      ville,
      adresse,
      localisation,
      status
    )
  ),

  locataire:users!reservations_locataire_id_fkey (
    id,
    nom,
    prenom,
    email,
    telephone,
    adresse,
    urgencephone
  ),

  proprietaire:users!reservations_proprietaire_id_fkey (
    id,
    nom,
    prenom,
    email,
    telephone,
    adresse,
    urgencephone
  )
''')
          .order(
        'created_at',
        ascending: false,
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Erreur récupération réservations : $e',
      );

      if (kDebugMode) {
        debugPrint('$stackTrace');
      }

      return [];
    }
  }

  // CLIENTS
  Future<int> _fetchTotalClients() async {
    try {
      final response = await _databaseService.supabase
          .from('users')
          .select('id')
          .eq('role', 'locataire');

      return response.length;
    } catch (e) {
      debugPrint(
        '❌ Erreur récupération clients : $e',
      );

      return 0;
    }
  }

  // ============================================================
// TOTAL FRAIS DE SERVICE
// ============================================================

  Future<int> _fetchTotalService() async {
    try {
      final response = await _databaseService.supabase
          .from('reservations')
          .select('frais_service, statut')
          .inFilter(
        'statut',
        ['confirmee', 'terminee'],
      );

      double total = 0;

      for (final reservation in response) {
        final rawFrais = reservation['frais_service'];

        if (rawFrais is num) {
          total += rawFrais.toDouble();
        } else {
          total += double.tryParse(
            rawFrais?.toString() ?? '',
          ) ??
              0;
        }
      }

      return total.round();
    } catch (e) {
      debugPrint(
        '❌ Erreur récupération total frais service : $e',
      );

      return 0;
    }
  }


  // CLIENTS
  Future<int> _fetchTotalOwner() async {
    try {
      final response = await _databaseService.supabase
          .from('users')
          .select('id')
          .eq('role', 'proprietaire');

      return response.length;
    } catch (e) {
      debugPrint(
        '❌ Erreur récupération propriétaire : $e',
      );

      return 0;
    }
  }

  // REVENUS
  Future<List<RevenueDataPoint>>
  _fetchRevenueData() async {
    try {
      final reservations = await _fetchAllReservations();

      const months = [
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

      final revenues = <String, int>{};
      final bookings = <String, int>{};

      for (final month in months) {
        revenues[month] = 0;
        bookings[month] = 0;
      }

      for (final reservation in reservations) {
        final statut = _normalizeStatus(
          reservation['statut'],
        );

        if (statut != 'confirmee' &&
            statut != 'confirme' &&
            statut != 'terminee' &&
            statut != 'termine') {
          continue;
        }

        final dateStr = reservation['date_debut'];

        if (dateStr == null) continue;

        final date = DateTime.tryParse(
          dateStr.toString(),
        );

        if (date == null) continue;

        final month = months[date.month - 1];

        final rawPrice = reservation['prix_total'];

        final price = rawPrice is num
            ? rawPrice.toDouble()
            : double.tryParse(
          rawPrice?.toString() ?? '',
        ) ??
            0;

        revenues[month] =
            (revenues[month] ?? 0) + price.round();

        bookings[month] =
            (bookings[month] ?? 0) + 1;
      }

      return months.map((month) {
        return RevenueDataPoint(
          month: month,
          revenus: revenues[month] ?? 0,
          reservations: bookings[month] ?? 0,
        );
      }).toList();
    } catch (e) {
      debugPrint(
        '❌ Erreur revenus : $e',
      );

      return const [];
    }
  }

  // ============================================================
  // VILLES
  // ============================================================

  Future<List<CityStats>> _fetchCityStats() async {
    try {
      final appartements =
      await _databaseService.fetchAppartements();

      final cityCounts = <String, int>{};

      const cityColors = {
        'Bamako': '#D4A843',
        'Sikasso': '#4A90D9',
        'Ségou': '#7B68EE',
        'Mopti': '#50C878',
        'Kayes': '#FF6B6B',
        'Koulikoro': '#FF9F43',
        'Bougouni': '#8B5CF6',
      };

      for (final appartement in appartements) {
        final ville = (appartement['ville'] ?? 'Inconnu')
            .toString()
            .trim();

        if (ville.isEmpty) continue;

        cityCounts[ville] =
            (cityCounts[ville] ?? 0) + 1;
      }

      final cities = cityCounts.entries.map((entry) {
        return CityStats(
          name: entry.key,
          value: entry.value,
          color: cityColors[entry.key] ?? '#D4A843',
        );
      }).toList();

      cities.sort(
            (a, b) => b.value.compareTo(a.value),
      );

      return cities.take(5).toList();
    } catch (e) {
      debugPrint(
        '❌ Erreur villes : $e',
      );

      return const [];
    }
  }

  // ============================================================
  // RÉSERVATIONS RÉCENTES
  // ============================================================

  Future<List<BookingData>>
  _fetchRecentBookings() async {
    try {
      final reservations =
      await _fetchAllReservations();

      const statutMap = {
        'en_attente': 'En attente',
        'confirmee': 'Confirmé',
        'confirme': 'Confirmé',
        'terminee': 'Terminé',
        'termine': 'Terminé',
        'annulee': 'Annulée',
        'annule': 'Annulée',
      };

      return reservations.take(5).map((reservation) {
        final appartement =
            reservation['appartement']
            as Map<String, dynamic>? ??
                {};

        final locataire =
            reservation['locataire']
            as Map<String, dynamic>? ??
                {};

        final statut = _normalizeStatus(
          reservation['statut'] ?? 'en_attente',
        );

        final nom =
        '${locataire['prenom'] ?? ''} '
            '${locataire['nom'] ?? ''}'
            .trim();

        final createdAt =
        DateTime.tryParse(
          reservation['created_at']?.toString() ?? '',
        );

        final residence =
            appartement['residence'] as Map<String, dynamic>? ?? {};

        return BookingData(
          id: _parseId(reservation['id']),
          propertyName:
          appartement['titre']?.toString() ??
              'Propriété',
          city:
          residence['ville']?.toString() ??
              'Ville inconnue',
          type:
          appartement['type']?.toString() ??
              'Type inconnu',
          price:
          '${reservation['prix_total'] ?? 0} FCFA',
          status:
          statutMap[statut] ?? statut,
          client:
          nom.isEmpty ? 'Client' : nom,
          date: createdAt,
        );
      }).toList();
    } catch (e) {
      debugPrint(
        '❌ Erreur réservations récentes : $e',
      );

      return const [];
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshDashboard() async {
    await loadDashboardData(
      forceRefresh: true,
    );
  }

  // ============================================================
  // CACHE
  // ============================================================

  void clearCache() {
    _dashboardData = null;
    _isCacheValid = false;
    _lastUpdate = DateTime.now();

    notifyListeners();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _normalizeStatus(dynamic value) {
    final status = value
        ?.toString()
        .trim()
        .toLowerCase();

    switch (status) {
      case 'confirmé':
      case 'confirme':
      case 'confirmee':
        return 'confirmee';

      case 'terminé':
      case 'termine':
      case 'terminee':
        return 'terminee';

      case 'annulée':
      case 'annule':
      case 'annulee':
        return 'annulee';

      case 'en attente':
      case 'en_attente':
        return 'en_attente';

      default:
        return status ?? '';
    }
  }

  int _parseId(dynamic value) {
    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  // ============================================================
  // ÉTAT
  // ============================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = '';
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _dashboardData = null;
    super.dispose();
  }
}