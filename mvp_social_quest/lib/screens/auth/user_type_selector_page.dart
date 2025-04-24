import 'package:flutter/material.dart';
import 'signup_page.dart';

/// 🤔 Choix du type de compte (utilisateur vs commerçant).
class UserTypeSelectorPage extends StatelessWidget {
  const UserTypeSelectorPage({Key? key}) : super(key: key);

  void _navigateTo(BuildContext ctx, String type) {
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => SignUpPage(userType: type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Création de compte")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.question_mark,
                size: 72,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 24),
              const Text(
                'Qui êtes-vous ?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildButton(context, 'Utilisateur', Icons.person, 'user'),
              const SizedBox(height: 12),
              _buildButton(context, 'Commerçant', Icons.store, 'merchant'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    IconData icon,
    String userType,
  ) {
    return ElevatedButton.icon(
      onPressed: () => _navigateTo(context, userType),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
