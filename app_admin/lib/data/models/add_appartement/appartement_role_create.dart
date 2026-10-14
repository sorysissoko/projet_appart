import 'package:flutter/material.dart';

class AppartementRoleCreate {
  final String description;
  final TimeOfDay heureArrive;
  final TimeOfDay heureDepart;
  final int nombreClient;
  final String fete;
  final String animaux;
  final String fumeur;

  const AppartementRoleCreate({
    required this.description,
    required this.heureArrive,
    required this.heureDepart,
    required this.nombreClient,
    required this.fete,
    required this.animaux,
    required this.fumeur,
  });



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
}