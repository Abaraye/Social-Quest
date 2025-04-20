import 'package:flutter/material.dart';
import 'package:mvp_social_quest/screens/auth/login_page.dart';
import './user_type_selector.dart';
import '../home/home_page.dart';

/// Écran d’accueil de l’application avec animations et choix de navigation.
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialisation des animations (fade + slide)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Continuer sans compte (mode invité)
  void _continueAsGuest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  /// Accès à la page de connexion
  void _openLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  /// Accès à la page de sélection du type de compte
  void _openUserTypeSelector() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserTypeSelectorPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🌐 Icône de bienvenue
                const Icon(
                  Icons.travel_explore,
                  size: 72,
                  color: Colors.deepPurple,
                ),

                const SizedBox(height: 24),

                const Text(
                  "Bienvenue sur Social Quest ✨",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 40),

                // 🔹 Créer un compte
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  onPressed: _openUserTypeSelector,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  label: const Text(
                    "Créer un compte",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 12),

                // 🔹 Se connecter
                OutlinedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text("Se connecter"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _openLoginPage,
                ),

                const SizedBox(height: 12),

                // 🔹 Continuer sans compte
                TextButton(
                  onPressed: _continueAsGuest,
                  child: const Text(
                    "On verra plus tard",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
