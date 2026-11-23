import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'page_home.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({super.key});

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool afficherMotDePasse = false;
  String? erreur;

  static const Color cyan = Color(0xFF00E5FF);
  static const Color blue = Color(0xFF6475FF);
  static const Color panel = Color(0xFF101A2B);

  Future<void> seConnecter() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      setState(() {
        erreur = 'Renseigne ton adresse e-mail et ton mot de passe.';
      });
      return;
    }

    setState(() {
      loading = true;
      erreur = null;
    });

    try {
      await ApiService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PageHome()),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        erreur = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

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
        TextField(
          controller: controller,
          obscureText: motDePasse && !afficherMotDePasse,
          keyboardType: motDePasse
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
          autocorrect: false,
          onSubmitted: motDePasse ? (_) => seConnecter() : null,
          decoration: InputDecoration(
            hintText: indication,
            prefixIcon: Icon(icone),
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

  Widget boutonConnexion() {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
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
          onTap: loading ? null : seConnecter,
          child: Center(
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 30,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      champConnexion(
                        titre: 'Adresse e-mail',
                        indication: 'joueur@email.com',
                        icone: Icons.alternate_email_rounded,
                        controller: emailController,
                      ),

                      const SizedBox(height: 22),

                      champConnexion(
                        titre: 'Mot de passe',
                        indication: 'Ton mot de passe',
                        icone: Icons.lock_outline_rounded,
                        controller: passwordController,
                        motDePasse: true,
                      ),

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

                      boutonConnexion(),

                      const SizedBox(height: 30),

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
