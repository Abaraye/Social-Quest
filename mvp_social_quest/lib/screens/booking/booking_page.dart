import 'package:flutter/material.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mes réservations')),
    body: const Center(child: Text('Aucune réservation pour le moment.')),
  );
}
