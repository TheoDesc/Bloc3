// Service permettant de construire les adresses des photos des LAN.
class ImageService {
  // Adresse IP du serveur Symfony accessible depuis le téléphone.
  static const String baseUrl = 'http://10.176.129.110';

  // Nom du site configuré dans Apache.
  static const String host = 'cesi.local';

  // Transforme le chemin de la photo en URL complète.
  static String? urlImage(String? image) {
    final chemin = image?.trim() ?? '';

    // Aucune image : on retourne null.
    if (chemin.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(chemin);

    // Si l'image possède déjà une URL complète,
    // on vérifie si elle provient de notre serveur local.
    if (uri != null && uri.hasScheme) {
      if (uri.host == host ||
          uri.host == 'www.cesi.local' ||
          uri.host == '10.176.129.110') {
        // Remplace le nom de domaine par l'adresse IP
        // utilisée par le téléphone.
        return Uri.parse(baseUrl)
            .replace(path: uri.path, query: uri.hasQuery ? uri.query : null)
            .toString();
      }

      // Conserve les anciennes URL complètes externes.
      return chemin;
    }

    // Transforme un chemin local en URL complète.
    final cheminNormalise = chemin.startsWith('/') ? chemin : '/$chemin';

    return '$baseUrl$cheminNormalise';
  }

  // Ajoute l'en-tête Host pour que le serveur Apache
  // reconnaisse le site cesi.local.
  static Map<String, String>? headersImage(String? image) {
    final chemin = image?.trim() ?? '';

    if (chemin.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(chemin);

    // Les images locales nécessitent cet en-tête.
    if (uri == null ||
        !uri.hasScheme ||
        uri.host == host ||
        uri.host == 'www.cesi.local' ||
        uri.host == '10.176.129.110') {
      return const {'Host': host};
    }

    // Les anciennes URL externes n'ont pas besoin de cet en-tête.
    return null;
  }
}
