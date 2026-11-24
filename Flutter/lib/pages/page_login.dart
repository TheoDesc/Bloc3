
// Import des composants graphiques Flutter.
import 'package:flutter/material.dart';

// Import du service qui communique avec l'API Symfony.
import '../services/api_service.dart';

// Import de la page d'accueil affichée après la connexion.
import 'page_home.dart';

// Page de connexion de l'application.
class PageLogin extends StatefulWidget {
  const PageLogin({super.key});

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  // Contrôleurs permettant de récupérer les identifiants saisis.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Indique si une connexion est en cours.
  bool loading = false;

  // Permet de choisir si le mot de passe est visible ou masqué.
  bool afficherMotDePasse = false;

  // Contient le message d'erreur éventuel lors de la connexion.
  String? erreur;

  // Couleurs utilisées dans l'interface de connexion.
  static const Color cyan = Color(0xFF00E5FF);
  static const Color blue = Color(0xFF6475FF);
  static const Color panel = Color(0xFF101A2B);

  // Vérifie les identifiants et tente de connecter l'utilisateur à l'API.
  Future<void> seConnecter() async {
    // Vérifie que l'adresse e-mail et le mot de passe sont renseignés.
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      setState(() {
        erreur = 'Renseigne ton adresse e-mail et ton mot de passe.';
      });
      return;
    }

    // Active le chargement et efface l'ancienne erreur.
    setState(() {
      loading = true;
      erreur = null;
    });

    try {
      // Envoie les identifiants au service API.
      // Le service récupère le token JWT renvoyé par Symfony.
      await ApiService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      // Vérifie que la page existe toujours avant de naviguer.
      if (!mounted) return;

      // Remplace la page de connexion par la page d'accueil.
      // L'utilisateur ne revient donc pas à la connexion avec le bouton retour.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PageHome()),
      );
    } catch (e) {
      if (!mounted) return;

      // Affiche le message renvoyé en cas d'échec de connexion.
      setState(() {
        erreur = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      // Arrête l'indicateur de chargement à la fin de la connexion.
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // Crée un champ de connexion réutilisable.
  // Le paramètre motDePasse permet de masquer ou d'afficher le texte.
  Widget champConnexion({
    required String titre,
    required String indication,
    required IconData icone,
    required TextEditingController controller,
    bool motDePasse = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre affiché au-dessus du champ.
        Text(
          titre.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF9BAAC0),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 10),

        // Champ permettant de saisir l'adresse e-mail ou le mot de passe.
        TextField(
          controller: controller,

          // Masque le contenu uniquement pour le mot de passe
          // lorsque l'utilisateur n'a pas demandé à l'afficher.
          obscureText: motDePasse && !afficherMotDePasse,

          // Adapte le clavier au type de donnée attendu.
          keyboardType: motDePasse
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,

          autocorrect: false,

          // Valide la connexion lorsque l'utilisateur appuie sur Entrée
          // depuis le champ du mot de passe.
          onSubmitted: motDePasse ? (_) => seConnecter() : null,

          decoration: InputDecoration(
            hintText: indication,
            prefixIcon: Icon(icone),

            // Ajoute un bouton pour afficher ou masquer le mot de passe.
            suffixIcon: motDePasse
                ? IconButton(
              onPressed: () {
                setState(() {
                  afficherMotDePasse = !afficherMotDePasse;
                });
              },
              icon: Icon(
                afficherMotDePasse
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            )
                : null,
          ),
        ),
      ],
    );
  }

  // Construit le bouton principal de connexion.
  Widget boutonConnexion() {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        // Dégradé utilisé pour mettre en valeur le bouton.
        gradient: const LinearGradient(colors: [cyan, blue]),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: cyan.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),

          // Désactive le bouton pendant une connexion.
          onTap: loading ? null : seConnecter,

          child: Center(
            // Affiche un indicateur pendant la connexion
            // ou le texte normal lorsque le chargement est terminé.
            child: loading
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
                Text(
                  'INITIALISER LA CONNEXION',
                  style: TextStyle(
                    color: Color(0xFF07111D),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF07111D),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Libère les contrôleurs lorsque la page de connexion est fermée.
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // Construit l'ensemble de l'écran de connexion.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Première décoration en arrière-plan.
          Positioned(
            top: -130,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cyan.withOpacity(0.07),
              ),
            ),
          ),

          // Deuxième décoration en arrière-plan.
          Positioned(
            bottom: -140,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blue.withOpacity(0.08),
              ),
            ),
          ),

          // Protège le contenu des zones occupées par le téléphone.
          SafeArea(
            child: Center(
              // Permet de faire défiler la page sur les petits écrans.
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 30,
                ),
                child: ConstrainedBox(
                  // Limite la largeur du formulaire sur les grands écrans.
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Partie supérieure avec le logo et le nom du projet.
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: panel,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: cyan.withOpacity(0.6),
                                  width: 1.3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: cyan.withOpacity(0.17),
                                    blurRadius: 35,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.memory_rounded,
                                color: cyan,
                                size: 51,
                              ),
                            ),

                            const SizedBox(height: 22),

                            const Text(
                              'LAN FRANCE',
                              style: TextStyle(
                                fontSize: 29,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'ESPORT EVENT NETWORK',
                              style: TextStyle(
                                color: cyan,
                                fontSize: 10,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 55),

                      // Titre et présentation de la connexion.
                      const Text(
                        'PLAYER ACCESS  /  01',
                        style: TextStyle(
                          color: cyan,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.8,
                        ),
                      ),

                      const SizedBox(height: 13),

                      const Text(
                        'Prêt à entrer\n'
                            'dans l’arène ?',
                        style: TextStyle(
                          fontSize: 32,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Connecte-toi pour découvrir les événements LAN et rejoindre la communauté.',
                        style: TextStyle(
                          color: Color(0xFF91A0B7),
                          height: 1.6,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Champ de saisie de l'adresse e-mail.
                      champConnexion(
                        titre: 'Adresse e-mail',
                        indication: 'joueur@email.com',
                        icone: Icons.alternate_email_rounded,
                        controller: emailController,
                      ),

                      const SizedBox(height: 22),

                      // Champ de saisie du mot de passe.
                      champConnexion(
                        titre: 'Mot de passe',
                        indication: 'Ton mot de passe',
                        icone: Icons.lock_outline_rounded,
                        controller: passwordController,
                        motDePasse: true,
                      ),

                      // Affiche un message si la connexion échoue.
                      if (erreur != null) ...[
                        const SizedBox(height: 18),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.redAccent.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.redAccent,
                              ),

                              const SizedBox(width: 10),

                              // Affiche le texte de l'erreur.
                              Expanded(
                                child: Text(
                                  erreur!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 27),

                      // Bouton permettant de lancer la connexion.
                      boutonConnexion(),

                      const SizedBox(height: 30),

                      // Mention affichée en bas de la page.
                      const Center(
                        child: Text(
                          'SYSTEM ONLINE  //  LAN FRANCE',
                          style: TextStyle(
                            color: Color(0xFF53647C),
                            fontSize: 9,
                            letterSpacing: 1.7,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
