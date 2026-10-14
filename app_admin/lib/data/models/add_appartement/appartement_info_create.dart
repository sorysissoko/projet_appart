class AppartementInfoCreate {
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

  AppartementInfoCreate({
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
  });

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