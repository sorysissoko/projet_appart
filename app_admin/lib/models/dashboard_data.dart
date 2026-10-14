import 'dart:ui';

class DashboardStats {
  final int totalAppartements;
  final int totalVillas;
  final int totalStudios;
  final int totalReservations;
  final int reservationsToday;
  final int reservationsEnAttente;
  final int reservationsConfirmees;
  final int reservationsTerminees;
  final int totalClients;
  final int totalOwner;
  final int totalService;

  const DashboardStats({
    required this.totalAppartements,
    required this.totalVillas,
    required this.totalStudios,
    required this.totalReservations,
    required this.reservationsToday,
    required this.reservationsEnAttente,
    required this.reservationsConfirmees,
    required this.reservationsTerminees,
    required this.totalClients,
    required this.totalOwner,
    required this.totalService,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalAppartements: json['totalAppartements'] ?? 0,
      totalVillas: json['totalVillas'] ?? 0,
      totalStudios: json['totalStudios'] ?? 0,
      totalReservations: json['totalReservations'] ?? 0,
      reservationsToday: json['reservationsToday'] ?? 0,
      reservationsEnAttente: json['reservationsEnAttente'] ?? 0,
      reservationsConfirmees: json['reservationsConfirmees'] ?? 0,
      reservationsTerminees: json['reservationsTerminees'] ?? 0,
      totalClients: json['totalClients'] ?? 0,
      totalOwner: json['totalOwner'] ?? 0,
      totalService: json['totalService'] ?? 0,

    );
  }

  DashboardStats copyWith({
    int? totalAppartements,
    int? totalVillas,
    int? totalStudios,
    int? totalReservations,
    int? reservationsToday,
    int? reservationsEnAttente,
    int? reservationsConfirmees,
    int? reservationsTerminees,
    int? totalClients,
    int? totalOwner,
    int? totalService,
  }) {
    return DashboardStats(
      totalAppartements: totalAppartements ?? this.totalAppartements,
      totalVillas: totalVillas ?? this.totalVillas,
      totalStudios: totalStudios ?? this.totalStudios,
      totalReservations: totalReservations ?? this.totalReservations,
      reservationsToday: reservationsToday ?? this.reservationsToday,
      reservationsEnAttente: reservationsEnAttente ?? this.reservationsEnAttente,
      reservationsConfirmees: reservationsConfirmees ?? this.reservationsConfirmees,
      reservationsTerminees: reservationsTerminees ?? this.reservationsTerminees,
      totalClients: totalClients ?? this.totalClients,
      totalOwner: totalOwner ?? this.totalOwner,
      totalService: totalService ?? this.totalService,
    );
  }
}

class CityStats {
  final String name;
  final int value;
  final String color;

  const CityStats({
    required this.name,
    required this.value,
    required this.color,
  });

  factory CityStats.fromJson(Map<String, dynamic> json) {
    return CityStats(
      name: json['name'] ?? '',
      value: json['value'] ?? 0,
      color: json['color'] ?? '#D4A843',
    );
  }

  Color get colorValue {
    try {
      final hex = color.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return const Color(0xFFD4A843);
    }
  }
}

class RevenueDataPoint {
  final String month;
  final int revenus;
  final int reservations;

  const RevenueDataPoint({
    required this.month,
    required this.revenus,
    required this.reservations,
  });

  factory RevenueDataPoint.fromJson(Map<String, dynamic> json) {
    return RevenueDataPoint(
      month: json['month'] ?? '',
      revenus: json['revenus'] ?? 0,
      reservations: json['reservations'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'revenus': revenus,
      'reservations': reservations,
    };
  }
}

class BookingData {
  final int id;
  final String propertyName;
  final String city;
  final String type;
  final String price;
  final String status;
  final String client;
  final DateTime? date;

  const BookingData({
    required this.id,
    required this.propertyName,
    required this.city,
    required this.type,
    required this.price,
    required this.status,
    required this.client,
    this.date,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      id: json['id'] ?? 0,
      propertyName: json['propertyName'] ?? json['name'] ?? '',
      city: json['city'] ?? json['ville'] ?? '',
      type: json['type'] ?? '',
      price: json['price'] ?? json['prix'] ?? '0 F',
      status: json['status'] ?? json['statut'] ?? 'En attente',
      client: json['client'] ?? '',
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
    );
  }
}

class DashboardData {
  final DashboardStats stats;
  final List<RevenueDataPoint> revenueData;
  final List<CityStats> cities;
  final List<BookingData> recentBookings;
  final DateTime lastUpdate;

  const DashboardData({
    required this.stats,
    required this.revenueData,
    required this.cities,
    required this.recentBookings,
    required this.lastUpdate,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      stats: DashboardStats.fromJson(json['stats'] ?? {}),
      revenueData: (json['revenueData'] as List? ?? [])
          .map((e) => RevenueDataPoint.fromJson(e))
          .toList(),
      cities: (json['cities'] as List? ?? [])
          .map((e) => CityStats.fromJson(e))
          .toList(),
      recentBookings: (json['recentBookings'] as List? ?? [])
          .map((e) => BookingData.fromJson(e))
          .toList(),
      lastUpdate: DateTime.tryParse(json['lastUpdate'] ?? '') ?? DateTime.now(),
    );
  }
}