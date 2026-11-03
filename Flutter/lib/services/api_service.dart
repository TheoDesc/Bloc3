
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lan.dart';

class ApiService {
  static const String baseUrl = 'http://10.176.129.110:8000';

  static String? token;

  static Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data['message'] ?? 'Identifiants incorrects',
      );
    }

    token = data['token'];

    if (token == null) {
      throw Exception('Aucun token JWT reçu.');
    }
  }

  static Future<List<LanModel>> getLans() async {
    if (token == null) {
      throw Exception('Vous devez être connecté.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/lans'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Impossible de récupérer les LAN.');
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

    return liste
        .map((item) => LanModel.fromJson(item))
        .toList();
  }
}
