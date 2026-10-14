class AppartementInfo {
  final String? id;
  final String? appartementId;
  final int chambre;
  final int salon;
  final int douche;
  final int cuisine;
  final int etage;
  final double taille;
  final bool serviceInclus;
  final bool internet;
  final bool stationnement;
  final bool meuble;
  final bool climatisation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppartementInfo({
    this.id,
    this.appartementId,
    required this.chambre,
    required this.salon,
    required this.douche,
    required this.cuisine,
    required this.etage,
    required this.taille,
    required this.serviceInclus,
    required this.internet,
    required this.stationnement,
    required this.meuble,
    required this.climatisation,
    this.createdAt,
    this.updatedAt,
  });

  factory AppartementInfo.fromMap(Map<String, dynamic> map) {
    return AppartementInfo(
      id: map['id']?.toString(),
      appartementId: map['appartement_id']?.toString(),
      chambre: map['chambre'] as int? ?? 0,
      salon: map['salon'] as int? ?? 0,
      douche: map['douche'] as int? ?? 0,
      cuisine: map['cuisine'] as int? ?? 0,
      etage: map['etage'] as int? ?? 0,
      taille: (map['taille'] as num?)?.toDouble() ?? 0.0,
      serviceInclus: _parseBool(map['service_inclus']),
      internet: _parseBool(map['internet']),
      stationnement: _parseBool(map['stationnement']),
      meuble: _parseBool(map['meuble']),
      climatisation: _parseBool(map['climatisation']),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'oui' || value.toLowerCase() == 'true';
    }
    if (value is int) {
      return value == 1;
    }
    return false;
  }

  Map<String, dynamic> toMap() {
    return {
      'chambre': chambre,
      'salon': salon,
      'douche': douche,
      'cuisine': cuisine,
      'etage': etage,
      'taille': taille,
      'service_inclus': serviceInclus ? 'Oui' : 'Non',
      'internet': internet ? 'Oui' : 'Non',
      'stationnement': stationnement ? 'Oui' : 'Non',
      'meuble': meuble ? 'Oui' : 'Non',
      'climatisation': climatisation ? 'Oui' : 'Non',
    };
  }
}