import 'package:flutter/material.dart';

/// Page réservée à l’historique des réservations utilisateur.
/// Pour l’instant, affichage d’un simple message statique.
/// Cette page pourra ensuite être connectée à Firestore ou un service dédié.
class ReservationsPage extends StatelessWidget {
  const ReservationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes réservations"),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Votre historique de réservations apparaîtra ici 📅',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
