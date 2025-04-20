import 'package:flutter/material.dart';
import 'signup_page.dart';

/// Page permettant à l'utilisateur de choisir son type de compte :
class UserTypeSelectorPage extends StatelessWidget {
  const UserTypeSelectorPage({super.key});

  /// Fonction de navigation vers la page de création de compte avec un rôle donné
  void _goToSignup(BuildContext context, String userType) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SignUpPage(userType: userType)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Création de compte"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // évite de forcer tout l’espace
            children: [
              // 🎯 Icône principale
              const Icon(
                Icons.question_answer,
                size: 72,
                color: Colors.deepPurple,
              ),

              const SizedBox(height: 24),

              const Text(
                'Qui êtes-vous ?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              const Text(
                'Sélectionne ton type de compte pour continuer',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 32),

              // 🔹 Bouton pour les utilisateurs
              _buildSelectorButton(
                context,
                label: 'Je suis un utilisateur',
                icon: Icons.person,
                color: Colors.deepPurple,
                userType: 'user',
              ),

              const SizedBox(height: 16),

              // 🔹 Bouton pour les commerçants
              _buildSelectorButton(
                context,
                label: 'Je suis un commerçant',
                icon: Icons.store,
                color: Colors.green,
                userType: 'merchant',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget réutilisable pour un bouton de sélection
  Widget _buildSelectorButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required String userType,
  }) {
    return ElevatedButton.icon(
      onPressed: () => _goToSignup(context, userType),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
