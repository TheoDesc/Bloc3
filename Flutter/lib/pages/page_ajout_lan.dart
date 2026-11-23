import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/api_service.dart';

class PageAjoutLan extends StatefulWidget {
  const PageAjoutLan({super.key});

  @override
  State<PageAjoutLan> createState() => _PageAjoutLanState();
}

class _PageAjoutLanState extends State<PageAjoutLan> {
  final formKey = GlobalKey<FormState>();

  final nomController = TextEditingController();
  final descriptionController = TextEditingController();
  final villeController = TextEditingController();
  final adresseController = TextEditingController();
  final jeuController = TextEditingController();
  final placesController = TextEditingController();
  final prixController = TextEditingController();
  final imageController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();

  static const Color cyan = Color(0xFF00E5FF);
  static const Color panel = Color(0xFF101A2B);

  DateTime dateDebut = DateTime.now().add(const Duration(days: 1));
  DateTime dateFin = DateTime.now().add(const Duration(days: 2));

  Position? position;

  bool chargementGPS = false;
  bool enregistrement = false;

  @override
  void dispose() {
    nomController.dispose();
    descriptionController.dispose();
    villeController.dispose();
    adresseController.dispose();
    jeuController.dispose();
    placesController.dispose();
    prixController.dispose();
    imageController.dispose();
    contactController.dispose();
    emailController.dispose();
    super.dispose();
  }

  String afficherDate(DateTime date) {
    final jour = date.day.toString().padLeft(2, '0');
    final mois = date.month.toString().padLeft(2, '0');

    return '$jour/$mois/${date.year}';
  }

  String envoyerDate(DateTime date) {
    return DateTime(date.year, date.month, date.day, 12).toIso8601String();
  }

  Future<void> choisirDate(bool debut) async {
    final dateInitiale = debut ? dateDebut : dateFin;

    final choix = await showDatePicker(
      context: context,
      initialDate: dateInitiale,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: debut ? 'Date de début' : 'Date de fin',
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: cyan, surface: panel),
          ),
          child: child!,
        );
      },
    );

    if (choix == null) return;

    setState(() {
      final nouvelleDate = DateTime(choix.year, choix.month, choix.day);

      if (debut) {
        dateDebut = nouvelleDate;

        if (!dateFin.isAfter(dateDebut)) {
          dateFin = dateDebut.add(const Duration(days: 1));
        }
      } else {
        dateFin = nouvelleDate;
      }
    });
  }

  Future<void> recupererPosition() async {
    setState(() {
      chargementGPS = true;
    });

    try {
      final serviceActif = await Geolocator.isLocationServiceEnabled();

      if (!serviceActif) {
        throw Exception('Active la localisation de ton téléphone.');
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('L’autorisation de localisation a été refusée.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Autorisation refusée définitivement. '
          'Modifie les permissions dans les paramètres du téléphone.',
        );
      }

      // Syntaxe compatible avec geolocator 12.0.0.
      final nouvellePosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );

      if (!mounted) return;

      setState(() {
        position = nouvellePosition;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Position GPS récupérée.'),
          backgroundColor: Color(0xFF168A71),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          chargementGPS = false;
        });
      }
    }
  }

  String? champObligatoire(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire.';
    }

    return null;
  }

  Widget champ({
    required String titre,
    required String indication,
    required TextEditingController controller,
    int lignes = 1,
    TextInputType clavier = TextInputType.text,
    String? Function(String?)? validation,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titre.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF9BAAC0),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          keyboardType: clavier,
          maxLines: lignes,
          validator: validation ?? champObligatoire,
          decoration: InputDecoration(
            hintText: indication,
            alignLabelWithHint: lignes > 1,
          ),
        ),
      ],
    );
  }

  Widget champDate({
    required String titre,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titre.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF9BAAC0),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 9),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFF26364D)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: cyan,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    afficherDate(date),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const Icon(
                  Icons.edit_calendar_outlined,
                  color: Color(0xFF8A9CB4),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget carteGPS() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cyan.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.my_location_rounded, color: cyan),
              SizedBox(width: 9),
              Text(
                'POSITION DU TÉLÉPHONE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (position == null)
            const Text(
              'Aucune position GPS récupérée.',
              style: TextStyle(color: Color(0xFF91A0B7), fontSize: 12),
            )
          else ...[
            Text(
              'Latitude : ${position!.latitude.toStringAsFixed(6)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 7),
            Text(
              'Longitude : ${position!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: chargementGPS ? null : recupererPosition,
              icon: chargementGPS
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cyan,
                      ),
                    )
                  : const Icon(Icons.gps_fixed_rounded),
              label: Text(
                chargementGPS
                    ? 'RÉCUPÉRATION EN COURS'
                    : 'RÉCUPÉRER MA POSITION GPS',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: cyan,
                side: const BorderSide(color: cyan),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> enregistrer() async {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) {
      return;
    }

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Récupère ta position GPS avant de continuer.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!dateFin.isAfter(dateDebut)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de fin doit être après la date de début.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final places = int.tryParse(placesController.text.trim());

    final prix = double.tryParse(
      prixController.text.trim().replaceAll(',', '.'),
    );

    if (places == null || places <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nombre de places doit être un entier positif.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (prix == null || prix < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le prix indiqué est invalide.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final imageUri = Uri.tryParse(imageController.text.trim());

    if (imageUri == null ||
        (imageUri.scheme != 'http' && imageUri.scheme != 'https')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Indique une URL valide pour la photo.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      enregistrement = true;
    });

    try {
      await ApiService.createLan({
        'nom': nomController.text.trim(),
        'description': descriptionController.text.trim(),
        'ville': villeController.text.trim(),
        'adresse': adresseController.text.trim(),
        'dateDebut': envoyerDate(dateDebut),
        'dateFin': envoyerDate(dateFin),
        'jeu': jeuController.text.trim(),
        'placesMax': places,
        'prix': prix,
        'image': imageController.text.trim(),
        'latitude': position!.latitude,
        'longitude': position!.longitude,
        'nomContact': contactController.text.trim(),
        'emailContact': emailController.text.trim(),
      });

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          enregistrement = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AJOUTER UNE LAN',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.4,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            children: [
              const Text(
                'NOUVEL ÉVÉNEMENT',
                style: TextStyle(
                  color: cyan,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Renseigne les informations de ta LAN.',
                style: TextStyle(color: Color(0xFF91A0B7), fontSize: 12),
              ),
              const SizedBox(height: 25),

              champ(
                titre: 'Nom de la LAN',
                indication: 'Ex : LAN Championship',
                controller: nomController,
              ),
              const SizedBox(height: 19),

              champ(
                titre: 'Description',
                indication: 'Présente ton événement...',
                controller: descriptionController,
                lignes: 4,
              ),
              const SizedBox(height: 19),

              champ(
                titre: 'Ville',
                indication: 'Ex : Rouen',
                controller: villeController,
              ),
              const SizedBox(height: 19),

              champ(
                titre: 'Adresse',
                indication: 'Adresse complète',
                controller: adresseController,
              ),
              const SizedBox(height: 19),

              champ(
                titre: 'Jeu',
                indication: 'Ex : Valorant, Counter-Strike...',
                controller: jeuController,
              ),
              const SizedBox(height: 19),

              champDate(
                titre: 'Date de début',
                date: dateDebut,
                onTap: () => choisirDate(true),
              ),
              const SizedBox(height: 19),

              champDate(
                titre: 'Date de fin',
                date: dateFin,
                onTap: () => choisirDate(false),
              ),
              const SizedBox(height: 19),

              champ(
                titre: 'Nombre de places',
                indication: 'Ex : 100',
                controller: placesController,
                clavier: TextInputType.number,
              ),
              const SizedBox(height: 19),

              champ(
                titre: 'Prix en euros',
                indication: 'Ex : 15.00',
                controller: prixController,
                clavier: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 19),

              champ(
                titre: 'Photo de la LAN (URL)',
                indication: 'https://exemple.com/photo.jpg',
                controller: imageController,
                validation: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La photo est obligatoire.';
                  }

                  final uri = Uri.tryParse(value.trim());

                  if (uri == null ||
                      (uri.scheme != 'http' && uri.scheme != 'https')) {
                    return 'Entre une URL valide.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 19),

              champ(
                titre: 'Nom du contact',
                indication: 'Nom de l’organisateur',
                controller: contactController,
              ),
              const SizedBox(height: 19),

              champ(
                titre: 'E-mail de contact',
                indication: 'contact@exemple.fr',
                controller: emailController,
                clavier: TextInputType.emailAddress,
                validation: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'L’adresse e-mail est obligatoire.';
                  }

                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(value.trim())) {
                    return 'Adresse e-mail invalide.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 25),
              carteGPS(),
              const SizedBox(height: 28),

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: enregistrement ? null : enregistrer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cyan,
                    foregroundColor: const Color(0xFF07111D),
                    disabledBackgroundColor: cyan.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: enregistrement
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            color: Color(0xFF07111D),
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline_rounded),
                            SizedBox(width: 10),
                            Text(
                              'ENREGISTRER LA LAN',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
