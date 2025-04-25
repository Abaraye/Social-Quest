// lib/screens/auth/auth_gate.dart
// -----------------------------------------------------------------------------
// AuthGate : widget enveloppant l'application pour gérer l'état d'authentification
// Affiche un loader pendant la connexion à Firebase Auth, puis
// laisse GoRouter (app_router.dart) effectuer les redirections.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// AuthGate
/// --------
/// • Affiche un indicateur de chargement tant que Firebase Auth
///   n'a pas renvoyé l'état de l'utilisateur.
/// • Une fois l'état connu (connecté ou non), on retourne [child]
///   qui correspond à l'arbre de navigation GoRouter.
/// • Toutes les redirections (welcome, login, signup, routes protégées)
///   sont gérées par `redirect` dans app_router.dart.
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key, required this.child}) : super(key: key);

  /// Arbre GoRouter à afficher une fois l'authentification résolue
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Tant que Firebase Auth n'a pas renvoyé de valeur
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Dès qu'on a l'état (user ou null), on affiche l'arbre GoRouter
        return child;
      },
    );
  }
}
