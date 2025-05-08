import 'package:flutter/material.dart';

class SlotFormPage extends StatelessWidget {
  const SlotFormPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Créer / éditer un créneau')),
    body: const Center(child: Text('Formulaire de créneau à venir.')),
  );
}
