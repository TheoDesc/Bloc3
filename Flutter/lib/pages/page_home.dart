import 'package:flutter/material.dart';

import '../models/lan.dart';
import '../services/api_service.dart';
import 'page_ajout_lan.dart';
import 'page_detail_lan.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  static const Color cyan = Color(0xFF00E5FF);
  static const Color blue = Color(0xFF6475FF);
  static const Color green = Color(0xFFB6FF5C);
  static const Color background = Color(0xFF070B16);
  static const Color panel = Color(0xFF101A2B);

  static const int limite = 10;

  final ScrollController scrollController = ScrollController();
  final rechercheController = TextEditingController();

  List<LanModel> lans = [];

  int page = 0;
  int total = 0;

  bool chargementInitial = true;
  bool chargementSuite = false;
  bool hasMore = true;

  String? erreur;
  String? erreurPagination;
  String recherche = '';

  @override
  void initState() {
    super.initState();

    scrollController.addListener(surveillerDefilement);
    chargerPremierePage();
  }

  @override
  void dispose() {
    scrollController.removeListener(surveillerDefilement);
    scrollController.dispose();
    rechercheController.dispose();
    super.dispose();
  }

  // Déclenche la pagination lorsque le défilement atteint 80 %.
  void surveillerDefilement() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;

    if (position.maxScrollExtent <= 0) return;

    final progression =
        position.pixels / position.maxScrollExtent;

    if (progression >= 0.8) {
      chargerPageSuivante();
    }
  }

  Future<void> chargerPremierePage() async {
    setState(() {
      chargementInitial = true;
      erreur = null;
      erreurPagination = null;
      page = 0;
      total = 0;
      hasMore = true;
      lans = [];
    });

    try {
      final resultat = await ApiService.getLansPage(
        page: 1,
        limit: limite,
      );

      if (!mounted) return;

      setState(() {
        lans = resultat.lans;
        page = resultat.page;
        total = resultat.total;
        hasMore = resultat.hasMore;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        erreur = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          chargementInitial = false;
        });
      }
    }
  }

  Future<void> actualiser() async {
    await chargerPremierePage();
  }

  Future<void> chargerPageSuivante() async {
    if (chargementInitial ||
        chargementSuite ||
        !hasMore) {
      return;
    }

    setState(() {
      chargementSuite = true;
      erreurPagination = null;
    });

    try {
      final resultat = await ApiService.getLansPage(
        page: page + 1,
        limit: limite,
      );

      if (!mounted) return;

      setState(() {
        lans.addAll(resultat.lans);
        page = resultat.page;
        total = resultat.total;
        hasMore = resultat.hasMore;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        erreurPagination =
            e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          chargementSuite = false;
        });
      }
    }
  }

  Future<void> ouvrirAjout() async {
    final resultat = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const PageAjoutLan(),
      ),
    );

    if (!mounted) return;

    if (resultat == true) {
      await actualiser();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La LAN a bien été enregistrée.'),
          backgroundColor: Color(0xFF168A71),
        ),
      );
    }
  }

  List<LanModel> filtrerLans() {
    if (recherche.trim().isEmpty) {
      return lans;
    }

    final texte = recherche.toLowerCase().trim();

    return lans.where((lan) {
      return lan.nom.toLowerCase().contains(texte) ||
          lan.ville.toLowerCase().contains(texte) ||
          lan.jeu.toLowerCase().contains(texte);
    }).toList();
  }

  String prixTexte(double prix) {
    if (prix == 0) return 'GRATUIT';
    return '${prix.toStringAsFixed(2)} €';
  }

  Widget etiquette(String texte, {Color couleur = cyan}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.10),
        border: Border.all(
          color: couleur.withOpacity(0.45),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texte,
        style: TextStyle(
          color: couleur,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget imageParDefaut(double hauteur) {
    return Container(
      height: hauteur,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF172C48),
            Color(0xFF242D5A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.sports_esports_rounded,
          color: cyan,
          size: 58,
        ),
      ),
    );
  }

  Widget imageLan(LanModel lan, {double hauteur = 170}) {
    final url = lan.image.trim();

    if (url.isEmpty ||
        (!url.startsWith('http://') &&
            !url.startsWith('https://'))) {
      return imageParDefaut(hauteur);
    }

    return Image.network(
      url,
      width: double.infinity,
      height: hauteur,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return imageParDefaut(hauteur);
      },
    );
  }

  Widget entete() {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: const Color(0xFF12263A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cyan.withOpacity(0.5),
            ),
          ),
          child: const Icon(
            Icons.memory_rounded,
            color: cyan,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LAN FRANCE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'ESPORT EVENT NETWORK',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF73849E),
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: green.withOpacity(0.35),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.circle, color: green, size: 7),
              SizedBox(width: 6),
              Text(
                'ONLINE',
                style: TextStyle(
                  color: green,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        IconButton(
          onPressed: actualiser,
          tooltip: 'Actualiser',
          icon: const Icon(
            Icons.refresh_rounded,
            color: cyan,
          ),
        ),
      ],
    );
  }

  Widget banniere() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF102B42),
            Color(0xFF171D3A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: cyan.withOpacity(0.28),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                etiquette('PLAYER HUB  /  FRANCE'),
                const SizedBox(height: 17),
                const Text(
                  'TROUVE TA\nPROCHAINE LAN.',
                  style: TextStyle(
                    fontSize: 23,
                    height: 1.18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 11),
                const Text(
                  'Repère les événements et rejoins la communauté.',
                  style: TextStyle(
                    color: Color(0xFFB0C1D8),
                    height: 1.5,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 17),
                const Text(
                  'DISCOVER  /  CONNECT  /  PLAY',
                  style: TextStyle(
                    color: cyan,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 76,
            height: 90,
            decoration: BoxDecoration(
              color: cyan.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cyan.withOpacity(0.22),
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.radar_rounded,
                  color: cyan,
                  size: 42,
                ),
                SizedBox(height: 7),
                Text(
                  'SCAN',
                  style: TextStyle(
                    color: cyan,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget enteteListe(List<LanModel> liste) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        entete(),
        const SizedBox(height: 25),
        banniere(),
        const SizedBox(height: 28),
        const Text(
          'CENTRE DE DÉCOUVERTE',
          style: TextStyle(
            color: cyan,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Explore les LAN.',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: rechercheController,
          onChanged: (value) {
            setState(() {
              recherche = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Nom, ville ou jeu...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: recherche.isNotEmpty
                ? IconButton(
              onPressed: () {
                rechercheController.clear();
                setState(() {
                  recherche = '';
                });
              },
              icon: const Icon(Icons.close_rounded),
            )
                : null,
          ),
        ),
        const SizedBox(height: 21),
        Row(
          children: [
            const Text(
              'ÉVÉNEMENTS DISPONIBLES',
              style: TextStyle(
                color: Color(0xFF9AABC1),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            Text(
              '${liste.length} / $total',
              style: const TextStyle(
                color: green,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget carteLan(LanModel lan, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 17),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF26364D),
        ),
      ),
      child: Material(
        color: Colors.transparent,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Stack(
                  children: [
                    imageLan(lan),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: etiquette(
                        'EVENT  //  ${(index + 1).toString().padLeft(2, '0')}',
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: etiquette(
                        prixTexte(lan.prix),
                        couleur: green,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lan.nom,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: cyan,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            lan.ville.isEmpty
                                ? 'Ville non renseignée'
                                : lan.ville,
                            style: const TextStyle(
                              color: Color(0xFF9AABC1),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.people_outline_rounded,
                          color: blue,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${lan.placesMax} PLACES',
                          style: const TextStyle(
                            color: Color(0xFF9AABC1),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(
                      color: Color(0xFF26364D),
                      height: 1,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.sports_esports_outlined,
                          color: green,
                          size: 17,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            lan.jeu.isEmpty
                                ? 'Jeu non renseigné'
                                : lan.jeu,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Text(
                          'DÉTAILS',
                          style: TextStyle(
                            color: cyan,
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: cyan,
                          size: 16,
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
    );
  }

  Widget piedListe() {
    if (chargementSuite) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(color: cyan),
        ),
      );
    }

    if (erreurPagination != null) {
      return Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              erreurPagination!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF9AABC1),
                fontSize: 12,
              ),
            ),
            TextButton(
              onPressed: chargerPageSuivante,
              child: const Text(
                'RÉESSAYER',
                style: TextStyle(color: cyan),
              ),
            ),
          ],
        ),
      );
    }

    if (hasMore) {
      return const Padding(
        padding: EdgeInsets.all(18),
        child: Center(
          child: Text(
            'Continue à défiler pour découvrir les prochaines LAN.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF71839D),
              fontSize: 11,
            ),
          ),
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Text(
          'TOUS LES ÉVÉNEMENTS ONT ÉTÉ CHARGÉS',
          style: TextStyle(
            color: Color(0xFF53647C),
            fontSize: 9,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget messageVide(List<LanModel> liste) {
    final aucunResultat = lans.isNotEmpty && liste.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.travel_explore_rounded,
            color: Color(0xFF53647C),
            size: 48,
          ),
          const SizedBox(height: 13),
          Text(
            aucunResultat
                ? 'Aucun résultat pour cette recherche.'
                : 'Aucune LAN disponible pour le moment.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9AABC1),
            ),
          ),
        ],
      ),
    );
  }

  Widget erreurChargement() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: cyan,
              size: 48,
            ),
            const SizedBox(height: 17),
            const Text(
              'CONNEXION INTERROMPUE',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              erreur ?? 'Impossible de charger les LAN.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8C9BB1),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: actualiser,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('RÉESSAYER'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cyan,
                foregroundColor: background,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (chargementInitial && lans.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: cyan),
        ),
      );
    }

    if (erreur != null && lans.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: erreurChargement(),
        ),
      );
    }

    final liste = filtrerLans();

    final nombreCartes = liste.isEmpty ? 1 : liste.length;
    final afficherPied = hasMore ||
        chargementSuite ||
        erreurPagination != null;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: cyan,
          onRefresh: actualiser,
          child: ListView.builder(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(19, 12, 19, 30),
            itemCount: 1 +
                nombreCartes +
                (afficherPied ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0) {
                return enteteListe(liste);
              }

              if (index <= nombreCartes) {
                if (liste.isEmpty) {
                  return messageVide(liste);
                }

                return carteLan(liste[index - 1], index);
              }

              return piedListe();
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ouvrirAjout,
        backgroundColor: cyan,
        foregroundColor: background,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'AJOUTER UNE LAN',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}