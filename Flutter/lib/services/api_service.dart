
// Permet d'utiliser les délais d'attente des requêtes HTTP.
import 'dart:async';

// Permet de convertir les données JSON reçues et envoyées à l'API.
import 'dart:convert';

// Bibliothèque utilisée pour effectuer les requêtes HTTP.
import 'package:http/http.dart' as http;

// Import du modèle utilisé pour représenter une LAN.
import '../models/lan.dart';

// Classe qui représente le résultat d'une requête de pagination.
class LanPage {
  // Liste des LAN récupérées pour la page demandée.
  final List<LanModel> lans;

  // Numéro de la page actuellement récupérée.
  final int page;

  // Nombre total de LAN présentes dans la base de données.
  final int total;

  // Indique s'il reste d'autres pages à récupérer.
  final bool hasMore;

  // Constructeur qui initialise les informations de pagination.
  LanPage({
    required this.lans,
    required this.page,
    required this.total,
    required this.hasMore,
  });
}

// Service central qui regroupe les communications avec l'API Symfony.
class ApiService {
  // Adresse IP du serveur Symfony accessible depuis le téléphone.
  static const String baseUrl = 'http://10.176.129.110';

  // Token JWT obtenu après une connexion réussie.
  // Il permet de prouver l'authentification lors des appels API.
  static String? token;

  // Prépare les en-têtes HTTP nécessaires aux requêtes authentifiées.
  static Map<String, String> get headers {
    // Vérifie qu'un utilisateur est bien connecté.
    if (token == null || token!.isEmpty) {
      throw Exception('Vous devez être connecté.');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',

      // Indique à Apache le nom du site Symfony à utiliser.
      'Host': 'cesi.local',

      // Transmet le token JWT pour authentifier la requête.
      'Authorization': 'Bearer $token',
    };
  }

  // Envoie les identifiants à Symfony pour obtenir un token JWT.
  static Future<void> login(String email, String password) async {
    print('LOGIN : début de la connexion');

    try {
      // Envoie une requête POST à la route de connexion de l'API.
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),

        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Host': 'cesi.local',
        },

        // Transmet l'adresse e-mail et le mot de passe au format JSON.
        body: jsonEncode({
          'username': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('LOGIN : réponse HTTP ${response.statusCode}');

      // Vérifie que Symfony a accepté la connexion.
      if (response.statusCode != 200) {
        throw Exception(
          'Erreur HTTP ${response.statusCode} : ${response.body}',
        );
      }

      // Convertit la réponse JSON en objet Dart.
      final data = jsonDecode(response.body);

      // Récupère le token JWT envoyé par Symfony.
      token = data['token'];

      print('LOGIN : token reçu = ${token != null && token!.isNotEmpty}');

      // Vérifie qu'un token a bien été reçu.
      if (token == null || token!.isEmpty) {
        throw Exception('Aucun token JWT reçu.');
      }

      print('LOGIN : connexion terminée');
    } on TimeoutException {
      // Affiche un message si le serveur ne répond pas dans le délai prévu.
      throw Exception('Le serveur ne répond pas après 10 secondes.');
    }
  }

  // Récupère toutes les LAN depuis l'API sans utiliser la pagination.
  // Cette méthode est conservée pour les appels qui en ont besoin.
  static Future<List<LanModel>> getLans() async {
    // Envoie une requête GET pour récupérer toutes les LAN.
    final response = await http.get(
      Uri.parse('$baseUrl/api/lans'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));

    // Vérifie que la requête a été traitée correctement.
    if (response.statusCode != 200) {
      throw Exception(
        'Erreur HTTP ${response.statusCode} : ${response.body}',
      );
    }

    // Convertit les données JSON reçues.
    final data = jsonDecode(response.body);

    final List<dynamic> liste;

    // Accepte plusieurs formats de réponse possibles de l'API.
    if (data is List) {
      liste = data;
    } else if (data is Map && data['lans'] is List) {
      liste = data['lans'];
    } else if (data is Map && data['data'] is List) {
      liste = data['data'];
    } else {
      throw Exception('Format de réponse API non reconnu.');
    }

    // Transforme chaque élément JSON en objet LanModel.
    return liste.map((item) => LanModel.fromJson(item)).toList();
  }

  // Récupère uniquement une page de LAN depuis l'API.
  static Future<LanPage> getLansPage({
    required int page,
    int limit = 10,
  }) async {
    // Prépare l'adresse de la requête avec les paramètres de pagination.
    // Par exemple : /api/lans?page=1&limit=10.
    final uri = Uri.parse('$baseUrl/api/lans').replace(
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    // Envoie une requête GET avec les en-têtes d'authentification.
    final response = await http.get(
      uri,
      headers: headers,
    ).timeout(const Duration(seconds: 10));

    // Vérifie que la requête a réussi.
    if (response.statusCode != 200) {
      throw Exception(
        'Erreur HTTP ${response.statusCode} : ${response.body}',
      );
    }

    // Convertit la réponse JSON.
    final data = jsonDecode(response.body);

    // Vérifie que l'API renvoie bien une liste de données paginées.
    if (data is! Map || data['data'] is! List) {
      throw Exception('Format de pagination API non reconnu.');
    }

    // Transforme les données reçues en objets LanModel.
    final List<LanModel> lans = (data['data'] as List)
        .map((item) => LanModel.fromJson(item))
        .toList();

    // Retourne les LAN ainsi que les informations de pagination.
    return LanPage(
      lans: lans,
      page: int.tryParse(data['page'].toString()) ?? page,
      total: int.tryParse(data['total'].toString()) ?? lans.length,
      hasMore: data['hasMore'] == true,
    );
  }

  // Envoie une nouvelle LAN à l'API avec ses coordonnées GPS.
  static Future<LanModel> createLan(Map<String, dynamic> donnees) async {
    // Envoie les informations de la nouvelle LAN au format JSON.
    final response = await http.post(
      Uri.parse('$baseUrl/api/lans'),
      headers: headers,
      body: jsonEncode(donnees),
    ).timeout(const Duration(seconds: 20));

    dynamic data;

    try {
      // Convertit la réponse du serveur en données Dart.
      data = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Réponse du serveur invalide.');
    }

    // Le code HTTP 201 indique que la LAN a été créée.
    if (response.statusCode != 201) {
      // Récupère le message d'erreur renvoyé par Symfony.
      final message = data is Map
          ? data['message']?.toString()
          : null;

      throw Exception(
        message ?? 'Impossible d’ajouter cette LAN.',
      );
    }

    // Vérifie que la réponse contient bien un objet JSON.
    if (data is! Map) {
      throw Exception('Les données reçues sont invalides.');
    }

    // Transforme la LAN créée en objet LanModel et la retourne.
    return LanModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }
}
