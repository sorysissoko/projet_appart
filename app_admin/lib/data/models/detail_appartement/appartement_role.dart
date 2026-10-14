import 'package:flutter/material.dart';

class AppartementRole {
  final String? id;
  final String? appartementId;
  final String? appartementInfoId;
  final String description;
  final TimeOfDay heureArrive;
  final TimeOfDay heureDepart;
  final int nombreClient;
  final String fete;
  final String animaux;
  final String fumeur;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppartementRole({
    this.id,
    this.appartementId,
    this.appartementInfoId,
    required this.description,
    required this.heureArrive,
    required this.heureDepart,
    required this.nombreClient,
    required this.fete,
    required this.animaux,
    required this.fumeur,
    this.createdAt,
    this.updatedAt,
  });

  factory AppartementRole.fromMap(Map<String, dynamic> map) {
    return AppartementRole(
      id: map['id']?.toString(),
      appartementId: map['appartement_id']?.toString(),
      appartementInfoId: map['appartement_info_id']?.toString(),
      description: map['description']?.toString() ?? '',
      heureArrive: _parseTime(map['heure_arrive']),
      heureDepart: _parseTime(map['heure_depart']),
      nombreClient: map['nombre_client'] as int? ?? 1,
      fete: map['fete']?.toString() ?? 'Pas de fêtes',
      animaux: map['animaux']?.toString() ?? 'Pas d animaux',
      fumeur: map['fumeur']?.toString() ?? 'Fumeurs non acceptés',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  static TimeOfDay _parseTime(dynamic value) {
    if (value == null) return const TimeOfDay(hour: 14, minute: 0);

    String timeStr = value.toString();
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 14;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return const TimeOfDay(hour: 14, minute: 0);
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'heure_arrive': '${heureArrive.hour.toString().padLeft(2, '0')}:${heureArrive.minute.toString().padLeft(2, '0')}',
      'heure_depart': '${heureDepart.hour.toString().padLeft(2, '0')}:${heureDepart.minute.toString().padLeft(2, '0')}',
      'nombre_client': nombreClient,
      'fete': fete,
      'animaux': animaux,
      'fumeur': fumeur,
    };
  }

  // Getters pour l'affichage
  String get heureArriveString =>
      '${heureArrive.hour.toString().padLeft(2, '0')}:${heureArrive.minute.toString().padLeft(2, '0')}';

  String get heureDepartString =>
      '${heureDepart.hour.toString().padLeft(2, '0')}:${heureDepart.minute.toString().padLeft(2, '0')}';

  bool get animauxAcceptes => animaux.contains('acceptés');
  bool get feteAcceptee => fete.contains('acceptées');
  bool get fumeursAcceptes => fumeur.contains('acceptés');
}