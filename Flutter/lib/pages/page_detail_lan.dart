import 'package:flutter/material.dart';

import '../models/lan.dart';

class PageDetailLan extends StatelessWidget {
  final LanModel lan;

  const PageDetailLan({required this.lan, super.key});

  static const Color cyan = Color(0xFF00E5FF);
  static const Color blue = Color(0xFF6475FF);
  static const Color green = Color(0xFFB6FF5C);
  static const Color panel = Color(0xFF101A2B);

  Widget imageParDefaut() {
    return Container(
      height: 285,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF172C48), Color(0xFF242D5A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.sports_esports_rounded, color: cyan, size: 75),
      ),
    );
  }

  Widget imageEvenement() {
    final url = lan.image.trim();

    if (url.isEmpty ||
        (!url.startsWith('http://') && !url.startsWith('https://'))) {
      return imageParDefaut();
    }

    return Image.network(
      url,
      width: double.infinity,
      height: 285,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return imageParDefaut();
      },
    );
  }

  Widget titreSection(String titre, String numero) {
    return Padding(
      padding: const EdgeInsets.only(top: 27, bottom: 14),
      child: Row(
        children: [
          Text(
            numero,
            style: const TextStyle(
              color: cyan,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              titre.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget information(
    IconData icone,
    String titre,
    String valeur, {
    Color couleur = cyan,
  }) {
    final texte = valeur.trim().isEmpty ? 'Non renseigné' : valeur;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF26364D)),
      ),
      child: Row(
        children: [
          Container(
            width: 41,
            height: 41,
            decoration: BoxDecoration(
              color: couleur.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icone, color: couleur, size: 19),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF71839D),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  texte,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget encartPrix(String prix) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF102438),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: cyan.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number_outlined, color: cyan, size: 28),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TARIF DE PARTICIPATION',
                  style: TextStyle(
                    color: Color(0xFF91A8C1),
                    fontSize: 9,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Prix de l’événement',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Text(
            prix,
            style: const TextStyle(
              color: green,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prix = lan.prix == 0 ? 'Gratuit' : '${lan.prix.toStringAsFixed(2)} €';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 285,
            pinned: true,
            backgroundColor: const Color(0xFF070B16),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  imageEvenement(),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.12),
                          const Color(0xFF070B16).withOpacity(0.96),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 21,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: cyan.withOpacity(0.15),
                            border: Border.all(color: cyan.withOpacity(0.7)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'EVENT DETAILS',
                            style: TextStyle(
                              color: cyan,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          lan.nom,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: cyan,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                lan.ville.isEmpty
                                    ? 'Ville non renseignée'
                                    : lan.ville,
                                style: const TextStyle(
                                  color: Color(0xFFB5C5D9),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(19, 10, 19, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  encartPrix(prix),

                  titreSection('Présentation', '01'),

                  Text(
                    lan.description.isEmpty
                        ? 'Aucune description disponible pour cet événement.'
                        : lan.description,
                    style: const TextStyle(
                      color: Color(0xFFAFBDD0),
                      fontSize: 13,
                      height: 1.7,
                    ),
                  ),

                  titreSection('Informations pratiques', '02'),

                  information(
                    Icons.sports_esports_outlined,
                    'Jeu',
                    lan.jeu,
                    couleur: green,
                  ),
                  information(Icons.location_on_outlined, 'Ville', lan.ville),
                  information(
                    Icons.map_outlined,
                    'Adresse',
                    lan.adresse,
                    couleur: blue,
                  ),
                  information(
                    Icons.calendar_today_outlined,
                    'Date de début',
                    lan.dateDebut,
                    couleur: blue,
                  ),
                  information(
                    Icons.event_outlined,
                    'Date de fin',
                    lan.dateFin,
                    couleur: blue,
                  ),
                  information(
                    Icons.people_outline_rounded,
                    'Capacité maximale',
                    '${lan.placesMax} places',
                    couleur: green,
                  ),

                  titreSection('Organisateur', '03'),

                  information(
                    Icons.person_outline_rounded,
                    'Nom du contact',
                    lan.nomContact,
                    couleur: blue,
                  ),
                  information(
                    Icons.alternate_email_rounded,
                    'Adresse e-mail',
                    lan.emailContact,
                    couleur: blue,
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: panel,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF26364D)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: cyan, size: 20),
                        SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            'Une question sur cet événement ? Contacte directement son organisateur grâce aux coordonnées indiquées ci-dessus.',
                            style: TextStyle(
                              color: Color(0xFF9AABC1),
                              fontSize: 11,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
