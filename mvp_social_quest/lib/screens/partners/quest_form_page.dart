import 'package:flutter/material.dart';

class QuestFormPage extends StatelessWidget {
  const QuestFormPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Créer / éditer une quête')),
    body: const Center(child: Text('Formulaire de quête à venir.')),
  );
}
