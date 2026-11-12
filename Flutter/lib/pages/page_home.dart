
import 'package:flutter/material.dart';
import '../models/lan.dart';
import '../services/api_service.dart';
import 'page_detail_lan.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  late Future<List<LanModel>> futureLans;

  @override
  void initState() {
    super.initState();
    futureLans = ApiService.getLans();
  }

  void actualiser() {
    setState(() {
      futureLans = ApiService.getLans();
    });
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFC12A63);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LAN France'),
        actions: [
          IconButton(
            onPressed: actualiser,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: FutureBuilder<List<LanModel>>(
        future: futureLans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: accent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 50,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: actualiser,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          final lans = snapshot.data ?? [];

          if (lans.isEmpty) {
            return const Center(
              child: Text('Aucun LAN disponible pour le moment.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: lans.length,
            itemBuilder: (context, index) {
              final lan = lans[index];

              return Card(
                color: const Color(0xFF161B24),
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PageDetailLan(lan: lan),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lan.nom,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: accent,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(lan.ville),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.sports_esports,
                              color: accent,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(lan.jeu),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.people,
                              color: accent,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text('${lan.placesMax} places maximum'),
                            const Spacer(),
                            Text(
                              '${lan.prix.toStringAsFixed(2)} €',
                              style: const TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Voir les détails →',
                            style: TextStyle(color: accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
