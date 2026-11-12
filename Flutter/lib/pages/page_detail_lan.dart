
import 'package:flutter/material.dart';
import '../models/lan.dart';

class PageDetailLan extends StatelessWidget {
  final LanModel lan;

  const PageDetailLan({
    required this.lan,
    super.key,
  });

  Widget information(IconData icon, String titre, String valeur) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFC12A63)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 4),
                Text(
                  valeur.isEmpty ? 'Non renseigné' : valeur,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du LAN'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lan.nom,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            Text(
              lan.description.isEmpty
                  ? 'Aucune description disponible.'
                  : lan.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            information(Icons.location_on, 'Ville', lan.ville),
            information(Icons.map, 'Adresse', lan.adresse),
            information(Icons.sports_esports, 'Jeu', lan.jeu),
            information(Icons.calendar_today, 'Date de début', lan.dateDebut),
            information(Icons.event, 'Date de fin', lan.dateFin),
            information(Icons.people, 'Places maximum', lan.placesMax.toString()),
            information(Icons.euro, 'Prix', '${lan.prix.toStringAsFixed(2)} €'),

            const Divider(height: 30),

            const Text(
              'Contact',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            information(Icons.person, 'Nom', lan.nomContact),
            information(Icons.email, 'E-mail', lan.emailContact),
          ],
        ),
      ),
    );
  }
}
