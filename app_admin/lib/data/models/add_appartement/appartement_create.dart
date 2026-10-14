class AppartementCreate {
  final String? residenceId;

  final String titre;
  final String adresse;
  final String ville;
  final String type;
  final double prix;
  final String description;
  final String nbreSejour;
  final Map<String, dynamic> equipements;

  const AppartementCreate({
    this.residenceId,
    required this.titre,
    required this.adresse,
    required this.ville,
    required this.type,
    required this.prix,
    required this.description,
    required this.nbreSejour,
    required this.equipements,
  });

  Map<String, dynamic> toMap() {
    return {
      'residence_id': residenceId,
      'titre': titre,
      'adresse': adresse,
      'ville': ville,
      'type': type,
      'prix': prix,
      'description': description,
      'nbre_sejour': nbreSejour,
      'autres_equipements': equipements,
    };
  }
}