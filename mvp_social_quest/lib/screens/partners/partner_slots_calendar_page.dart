import 'package:flutter/material.dart';

class PartnerSlotsCalendarPage extends StatelessWidget {
  const PartnerSlotsCalendarPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Créneaux disponibles')),
    body: const Center(child: Text('Calendrier des créneaux.')),
  );
}
