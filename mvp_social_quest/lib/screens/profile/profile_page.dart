import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mvp_social_quest/screens/auth/welcome_page.dart';
import 'package:mvp_social_quest/screens/auth/login_page.dart';
import 'package:mvp_social_quest/screens/auth/user_type_selector_page.dart';
import 'package:mvp_social_quest/services/auth/auth_service.dart';

/// 👤 Page Profil
///   - Si non connecté : propose inscription ou connexion
///   - Sinon : affiche email, actions de profil et bouton de déconnexion
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // ↪ Utilisateur invité
      return Scaffold(
        appBar: AppBar(
          title: const Text("Mon profil"),
          backgroundColor: Colors.deepPurple,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.travel_explore,
                size: 72,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserTypeSelectorPage(),
                      ),
                    ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text(
                  "Créer un compte",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text("Se connecter"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                "Vous n’êtes pas encore connecté.",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // ↪ Utilisateur connecté
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Avatar par défaut
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.deepPurple.shade100,
              child: const Icon(
                Icons.person,
                size: 40,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.email ?? 'Utilisateur inconnu',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),

            // Options de profil
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.present_to_all),
                    title: const Text('Mes récompenses'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap:
                        () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Fonctionnalité à venir"),
                          ),
                        ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Paramètres du compte'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap:
                        () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Fonctionnalité à venir"),
                          ),
                        ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bouton Déconnexion
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.power, color: Colors.white),
                label: const Text(
                  'Se déconnecter',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () async {
                  await AuthService.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomePage()),
                      (route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Déconnecté avec succès')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
