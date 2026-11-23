import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/lan.dart';

class LanPage {
  final List<LanModel> lans;
  final int page;
  final int total;
  final bool hasMore;

  LanPage({
    required this.lans,
    required this.page,
    required this.total,
    required this.hasMore,
  });
}

class ApiService {
  static const String baseUrl = 'http://10.176.129.110';

  static String? token;

  static Map<String, String> get headers {
    if (token == null || token!.isEmpty) {
      throw Exception('Vous devez être connecté.');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Host': 'cesi.local',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<void> login(String email, String password) async {
    print('LOGIN : début de la connexion');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Host': 'cesi.local',
        },
        body: jsonEncode({
          'username': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('LOGIN : réponse HTTP ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Erreur HTTP ${response.statusCode} : ${response.body}',
        );
      }

      final data = jsonDecode(response.body);

      token = data['token'];

      print('LOGIN : token reçu = ${token != null && token!.isNotEmpty}');

      if (token == null || token!.isEmpty) {
        throw Exception('Aucun token JWT reçu.');
      }

      print('LOGIN : connexion terminée');
    } on TimeoutException {
      throw Exception('Le serveur ne répond pas après 10 secondes.');
    }
  }

  // Ancienne méthode conservée pour les appels qui récupèrent toute la liste.
  static Future<List<LanModel>> getLans() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/lans'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur HTTP ${response.statusCode} : ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    final List<dynamic> liste;

    if (data is List) {
      liste = data;
    } else if (data is Map && data['lans'] is List) {
      liste = data['lans'];
    } else if (data is Map && data['data'] is List) {
      liste = data['data'];
    } else {
      throw Exception('Format de réponse API non reconnu.');
    }

    return liste.map((item) => LanModel.fromJson(item)).toList();
  }

  // Récupère une seule page de LAN.
  static Future<LanPage> getLansPage({
    required int page,
    int limit = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/api/lans').replace(
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: headers,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur HTTP ${response.statusCode} : ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    if (data is! Map || data['data'] is! List) {
      throw Exception('Format de pagination API non reconnu.');
    }

    final List<LanModel> lans = (data['data'] as List)
        .map((item) => LanModel.fromJson(item))
        .toList();

    return LanPage(
      lans: lans,
      page: int.tryParse(data['page'].toString()) ?? page,
      total: int.tryParse(data['total'].toString()) ?? lans.length,
      hasMore: data['hasMore'] == true,
    );
  }

  // Ajoute une LAN avec les coordonnées GPS du téléphone.
  static Future<LanModel> createLan(Map<String, dynamic> donnees) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/lans'),
      headers: headers,
      body: jsonEncode(donnees),
    ).timeout(const Duration(seconds: 20));

    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Réponse du serveur invalide.');
    }

    if (response.statusCode != 201) {
      final message = data is Map
          ? data['message']?.toString()
          : null;

      throw Exception(
        message ?? 'Impossible d’ajouter cette LAN.',
      );
    }

    if (data is! Map) {
      throw Exception('Les données reçues sont invalides.');
    }

    return LanModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }
}