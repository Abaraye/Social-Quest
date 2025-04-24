import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/home_page.dart';
import 'welcome_page.dart';

/// 🚪 AuthGate : widget racine qui redirige
/// l’utilisateur vers HomePage s’il est connecté,
/// sinon vers WelcomePage.
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 🔄 Affiche un loader tant que l’état d’authent est en attente
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 👤 Si un User existe → page principale
        if (snapshot.hasData) {
          return const HomePage();
        }

        // 🔑 Sinon → page de bienvenue
        return const WelcomePage();
      },
    );
  }
}
