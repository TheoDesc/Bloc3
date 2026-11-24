
// Modèle qui représente une LAN dans l'application Flutter.
class LanModel {
  // Identifiant unique de la LAN dans la base de données.
  final int id;

  // Informations principales de la LAN.
  final String nom;
  final String description;
  final String ville;
  final String adresse;

  // Dates de début et de fin de l'événement.
  final String dateDebut;
  final String dateFin;

  // Informations sur le jeu et les places disponibles.
  final String jeu;
  final int placesMax;
  final double prix;

  // Chemin ou adresse de la photo de la LAN.
  final String image;

  // Coordonnées GPS de l'événement.
  // Le symbole ? indique que ces valeurs peuvent être nulles.
  final double? latitude;
  final double? longitude;

  // Informations de la personne à contacter.
  final String nomContact;
  final String emailContact;

  // Constructeur : permet de créer un objet LanModel.
  // Les champs obligatoires doivent être renseignés.
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

  // Crée un objet LanModel à partir des données JSON reçues de l'API.
  factory LanModel.fromJson(Map<String, dynamic> json) {
    return LanModel(
      // Convertit les valeurs reçues dans leur type Dart.
      // Une valeur par défaut est utilisée si la conversion échoue.
      id: int.tryParse(json['id'].toString()) ?? 0,

      nom: json['nom']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      ville: json['ville']?.toString() ?? '',
      adresse: json['adresse']?.toString() ?? '',

      // Récupère les dates sous forme de chaînes de caractères.
      dateDebut: json['dateDebut']?.toString() ?? '',
      dateFin: json['dateFin']?.toString() ?? '',

      jeu: json['jeu']?.toString() ?? '',

      // Convertit le nombre de places en entier.
      placesMax: int.tryParse(json['placesMax'].toString()) ?? 0,

      // Convertit le prix en nombre décimal.
      prix: double.tryParse(json['prix'].toString()) ?? 0,

      image: json['image']?.toString() ?? '',

      // Les coordonnées GPS peuvent être absentes.
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),

      nomContact: json['nomContact']?.toString() ?? '',
      emailContact: json['emailContact']?.toString() ?? '',
    );
  }
}
