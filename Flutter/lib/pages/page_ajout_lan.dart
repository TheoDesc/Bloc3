
// Import des composants graphiques Flutter.
import 'package:flutter/material.dart';

// Permet de récupérer la position GPS du téléphone.
import 'package:geolocator/geolocator.dart';

// Service qui communique avec l'API Symfony.
import '../services/api_service.dart';

// Page permettant d'ajouter une nouvelle LAN.
class PageAjoutLan extends StatefulWidget {
  const PageAjoutLan({super.key});

  @override
  State<PageAjoutLan> createState() => _PageAjoutLanState();
}

class _PageAjoutLanState extends State<PageAjoutLan> {
  // Clé permettant de contrôler et de valider le formulaire.
  final formKey = GlobalKey<FormState>();

  // Contrôleurs permettant de récupérer le contenu des champs.
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

  // Couleurs utilisées pour personnaliser l'interface.
  static const Color cyan = Color(0xFF00E5FF);
  static const Color panel = Color(0xFF101A2B);

  // Dates proposées par défaut : demain et après-demain.
  DateTime dateDebut = DateTime.now().add(const Duration(days: 1));
  DateTime dateFin = DateTime.now().add(const Duration(days: 2));

  // Position GPS récupérée depuis le téléphone.
  Position? position;

  // Indique si une récupération GPS est en cours.
  bool chargementGPS = false;

  // Indique si l'enregistrement de la LAN est en cours.
  bool enregistrement = false;

  // Libère les contrôleurs lorsque la page est fermée.
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

  // Formate une date pour l'afficher au format jour/mois/année.
  String afficherDate(DateTime date) {
    final jour = date.day.toString().padLeft(2, '0');
    final mois = date.month.toString().padLeft(2, '0');

    return '$jour/$mois/${date.year}';
  }

  // Formate une date pour l'envoyer à l'API Symfony.
  // L'heure est fixée à midi pour éviter certains décalages de date.
  String envoyerDate(DateTime date) {
    return DateTime(date.year, date.month, date.day, 12).toIso8601String();
  }

  // Ouvre le calendrier pour choisir la date de début ou de fin.
  Future<void> choisirDate(bool debut) async {
    final dateInitiale = debut ? dateDebut : dateFin;

    final choix = await showDatePicker(
      context: context,
      initialDate: dateInitiale,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: debut ? 'Date de début' : 'Date de fin',

      // Personnalise les couleurs du calendrier.
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: cyan,
              surface: panel,
            ),
          ),
          child: child!,
        );
      },
    );

    // Ne fait rien si l'utilisateur ferme le calendrier sans choisir.
    if (choix == null) return;

    setState(() {
      final nouvelleDate = DateTime(choix.year, choix.month, choix.day);

      if (debut) {
        dateDebut = nouvelleDate;

        // Si la date de fin n'est plus valide, elle est décalée d'un jour.
        if (!dateFin.isAfter(dateDebut)) {
          dateFin = dateDebut.add(const Duration(days: 1));
        }
      } else {
        dateFin = nouvelleDate;
      }
    });
  }

  // Récupère la position GPS actuelle du téléphone.
  Future<void> recupererPosition() async {
    setState(() {
      chargementGPS = true;
    });

    try {
      // Vérifie que le service de localisation du téléphone est activé.
      final serviceActif = await Geolocator.isLocationServiceEnabled();

      if (!serviceActif) {
        throw Exception('Active la localisation de ton téléphone.');
      }

      // Vérifie si l'application possède l'autorisation GPS.
      LocationPermission permission = await Geolocator.checkPermission();

      // Demande l'autorisation si elle n'a pas encore été accordée.
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('L’autorisation de localisation a été refusée.');
      }

      // Gère le cas où l'autorisation a été définitivement refusée.
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Autorisation refusée définitivement. '
              'Modifie les permissions dans les paramètres du téléphone.',
        );
      }

      // Récupère les coordonnées GPS avec une précision élevée.
      // Syntaxe compatible avec geolocator 12.0.0.
      final nouvellePosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );

      // Vérifie que la page existe toujours avant de la modifier.
      if (!mounted) return;

      setState(() {
        position = nouvellePosition;
      });

      // Informe l'utilisateur que la position a été récupérée.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Position GPS récupérée.'),
          backgroundColor: Color(0xFF168A71),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Affiche le message si la récupération GPS échoue.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      // Arrête l'indicateur de chargement.
      if (mounted) {
        setState(() {
          chargementGPS = false;
        });
      }
    }
  }

  // Vérifie qu'un champ obligatoire n'est pas vide.
  String? champObligatoire(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire.';
    }

    return null;
  }

  // Crée un champ de saisie réutilisable dans le formulaire.
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
        // Affiche le titre du champ.
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

        // Champ de saisie associé à son contrôleur.
        TextFormField(
          controller: controller,
          keyboardType: clavier,
          maxLines: lignes,

          // Utilise la validation fournie ou la validation obligatoire.
          validator: validation ?? champObligatoire,

          decoration: InputDecoration(
            hintText: indication,
            alignLabelWithHint: lignes > 1,
          ),
        ),
      ],
    );
  }

  // Crée un bouton réutilisable pour sélectionner une date.
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

        // Le clic ouvre le calendrier.
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 17,
            ),
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

                // Affiche la date sélectionnée.
                Expanded(
                  child: Text(
                    afficherDate(date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
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

  // Affiche les coordonnées GPS et le bouton de récupération.
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

          // Affiche les coordonnées uniquement si elles sont disponibles.
          if (position == null)
            const Text(
              'Aucune position GPS récupérée.',
              style: TextStyle(
                color: Color(0xFF91A0B7),
                fontSize: 12,
              ),
            )
          else ...[
            Text(
              'Latitude : ${position!.latitude.toStringAsFixed(6)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Longitude : ${position!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,

            // Le bouton est désactivé pendant la récupération GPS.
            child: OutlinedButton.icon(
              onPressed: chargementGPS ? null : recupererPosition,

              // Affiche un indicateur pendant le chargement.
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

  // Vérifie les informations et envoie la nouvelle LAN à l'API.
  Future<void> enregistrer() async {
    // Ferme le clavier avant de valider le formulaire.
    FocusScope.of(context).unfocus();

    // Arrête l'enregistrement si un champ obligatoire est invalide.
    if (!formKey.currentState!.validate()) {
      return;
    }

    // La position GPS est obligatoire pour créer une LAN.
    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Récupère ta position GPS avant de continuer.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Vérifie que la date de fin est après celle du début.
    if (!dateFin.isAfter(dateDebut)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de fin doit être après la date de début.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Convertit les valeurs numériques saisies.
    final places = int.tryParse(placesController.text.trim());

    final prix = double.tryParse(
      prixController.text.trim().replaceAll(',', '.'),
    );

    // Vérifie que le nombre de places est un entier positif.
    if (places == null || places <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nombre de places doit être un entier positif.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Vérifie que le prix est un nombre valide et positif ou nul.
    if (prix == null || prix < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le prix indiqué est invalide.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Vérifie que l'adresse de la photo est une URL HTTP ou HTTPS.
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

    // Active l'indicateur de chargement pendant l'enregistrement.
    setState(() {
      enregistrement = true;
    });

    try {
      // Envoie toutes les informations de la LAN à l'API Symfony.
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

        // Ajoute les coordonnées GPS récupérées sur le téléphone.
        'latitude': position!.latitude,
        'longitude': position!.longitude,

        'nomContact': contactController.text.trim(),
        'emailContact': emailController.text.trim(),
      });

      if (!mounted) return;

      // Ferme le formulaire et indique à la page précédente
      // qu'une nouvelle LAN a été ajoutée.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      // Affiche l'erreur renvoyée par le service API.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      // Réactive le bouton lorsque l'opération est terminée.
      if (mounted) {
        setState(() {
          enregistrement = false;
        });
      }
    }
  }

  // Construit l'ensemble de la page d'ajout d'une LAN.
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

          // La liste permet de faire défiler le formulaire sur le téléphone.
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
                style: TextStyle(
                  color: Color(0xFF91A0B7),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 25),

              // Champ du nom de la LAN.
              champ(
                titre: 'Nom de la LAN',
                indication: 'Ex : LAN Championship',
                controller: nomController,
              ),

              const SizedBox(height: 19),

              // Champ de description de l'événement.
              champ(
                titre: 'Description',
                indication: 'Présente ton événement...',
                controller: descriptionController,
                lignes: 4,
              ),

              const SizedBox(height: 19),

              // Champ de la ville où se déroule la LAN.
              champ(
                titre: 'Ville',
                indication: 'Ex : Rouen',
                controller: villeController,
              ),

              const SizedBox(height: 19),

              // Champ de l'adresse complète.
              champ(
                titre: 'Adresse',
                indication: 'Adresse complète',
                controller: adresseController,
              ),

              const SizedBox(height: 19),

              // Champ du jeu principal de l'événement.
              champ(
                titre: 'Jeu',
                indication: 'Ex : Valorant, Counter-Strike...',
                controller: jeuController,
              ),

              const SizedBox(height: 19),

              // Sélection de la date de début.
              champDate(
                titre: 'Date de début',
                date: dateDebut,
                onTap: () => choisirDate(true),
              ),

              const SizedBox(height: 19),

              // Sélection de la date de fin.
              champDate(
                titre: 'Date de fin',
                date: dateFin,
                onTap: () => choisirDate(false),
              ),

              const SizedBox(height: 19),

              // Champ du nombre maximum de joueurs.
              champ(
                titre: 'Nombre de places',
                indication: 'Ex : 100',
                controller: placesController,
                clavier: TextInputType.number,
              ),

              const SizedBox(height: 19),

              // Champ du prix de participation.
              champ(
                titre: 'Prix en euros',
                indication: 'Ex : 15.00',
                controller: prixController,
                clavier: const TextInputType.numberWithOptions(decimal: true),
              ),

              const SizedBox(height: 19),

              // Champ contenant actuellement l'URL de la photo.
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

              // Informations sur la personne qui organise l'événement.
              champ(
                titre: 'Nom du contact',
                indication: 'Nom de l’organisateur',
                controller: contactController,
              ),

              const SizedBox(height: 19),

              // Champ de l'adresse e-mail du contact.
              champ(
                titre: 'E-mail de contact',
                indication: 'contact@exemple.fr',
                controller: emailController,
                clavier: TextInputType.emailAddress,
                validation: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'L’adresse e-mail est obligatoire.';
                  }

                  if (!RegExp(r'^[^@\s]+@[^@\s]+\\.[^@\s]+$')
                      .hasMatch(value.trim())) {
                    return 'Adresse e-mail invalide.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 25),

              // Affiche le bloc de récupération de la position GPS.
              carteGPS(),

              const SizedBox(height: 28),

              // Bouton final d'enregistrement de la LAN.
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

                  // Affiche un chargement ou le texte du bouton.
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
