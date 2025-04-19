// lib/screens/reservations_page.dart

import 'package:flutter/material.dart';

class ReservationsPage extends StatelessWidget {
  const ReservationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Votre historique de réservations apparaîtra ici 📅',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
