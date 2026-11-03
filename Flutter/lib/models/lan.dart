
class LanModel {
  final int id;
  final String nom;
  final String description;
  final String ville;
  final String adresse;
  final String dateDebut;
  final String dateFin;
  final String jeu;
  final int placesMax;
  final double prix;
  final String image;
  final double? latitude;
  final double? longitude;
  final String nomContact;
  final String emailContact;

  LanModel({
    required this.id,
    required this.nom,
    required this.description,
    required this.ville,
    required this.adresse,
    required this.dateDebut,
    required this.dateFin,
    required this.jeu,
    required this.placesMax,
    required this.prix,
    required this.image,
    this.latitude,
    this.longitude,
    required this.nomContact,
    required this.emailContact,
  });

  factory LanModel.fromJson(Map<String, dynamic> json) {
    return LanModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nom: json['nom']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      ville: json['ville']?.toString() ?? '',
      adresse: json['adresse']?.toString() ?? '',
      dateDebut: json['dateDebut']?.toString() ?? '',
      dateFin: json['dateFin']?.toString() ?? '',
      jeu: json['jeu']?.toString() ?? '',
      placesMax: int.tryParse(json['placesMax'].toString()) ?? 0,
      prix: double.tryParse(json['prix'].toString()) ?? 0,
      image: json['image']?.toString() ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      nomContact: json['nomContact']?.toString() ?? '',
      emailContact: json['emailContact']?.toString() ?? '',
    );
  }
}
