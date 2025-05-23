import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Page qui propose « Utilisateur » ou « Commerçant ».
class UserTypeSelectorPage extends StatelessWidget {
  const UserTypeSelectorPage({super.key});

  void _goToSignUp(BuildContext context, String type) =>
      context.go('/signup/$type');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir votre profil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Je suis un utilisateur'),
              onPressed: () => _goToSignUp(context, 'user'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.store),
              label: const Text('Je suis un commerçant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white, // ← texte et icône en blanc
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: () => _goToSignUp(context, 'merchant'),
            ),
          ],
        ),
      ),
    );
  }
}
