
// Import des composants nécessaires pour créer l'application Flutter.
import 'package:flutter/material.dart';

// Import de la page affichée au démarrage de l'application.
import 'pages/page_login.dart';

// Point d'entrée principal de l'application Flutter.
void main() {
  // Lance l'application en créant le widget MyApp.
  runApp(const MyApp());
}

// Widget principal qui configure toute l'application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Couleurs principales utilisées dans le thème de l'application.
  static const Color background = Color(0xFF070B16);
  static const Color panel = Color(0xFF101A2B);
  static const Color cyan = Color(0xFF00E5FF);

  // Construit l'application et définit son apparence générale.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Masque la bannière DEBUG affichée par Flutter en mode développement.
      debugShowCheckedModeBanner: false,

      // Nom de l'application.
      title: 'LAN France',

      // Thème graphique utilisé par l'ensemble des pages.
      theme: ThemeData(
        // Active Material 3 pour les composants graphiques.
        useMaterial3: true,

        // Définit un thème sombre pour l'application.
        brightness: Brightness.dark,

        // Couleur de fond générale des pages.
        scaffoldBackgroundColor: background,

        // Définit les couleurs principales à partir du cyan.
        colorScheme: ColorScheme.fromSeed(
          seedColor: cyan,
          brightness: Brightness.dark,
          surface: panel,
        ),

        // Police de caractères utilisée dans l'application.
        fontFamily: 'Roboto',

        // Apparence générale des barres supérieures.
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        // Apparence générale des champs de saisie.
        inputDecorationTheme: InputDecorationTheme(
          // Remplit les champs avec une couleur de fond.
          filled: true,
          fillColor: panel,

          // Apparence du texte indicatif dans les champs.
          hintStyle: const TextStyle(
            color: Color(0xFF65738B),
            fontSize: 13,
          ),

          // Couleur des icônes placées dans les champs.
          prefixIconColor: cyan,

          // Bordure normale des champs.
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: Color(0xFF26364D),
            ),
          ),

          // Bordure utilisée lorsque le champ n'est pas sélectionné.
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: Color(0xFF26364D),
            ),
          ),

          // Bordure affichée lorsque l'utilisateur sélectionne un champ.
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: cyan,
              width: 1.5,
            ),
          ),
        ),
      ),

      // Première page affichée lorsque l'application démarre.
      home: const PageLogin(),
    );
  }
}
