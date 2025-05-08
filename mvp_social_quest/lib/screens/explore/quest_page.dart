import 'package:flutter/material.dart';

class QuestPage extends StatelessWidget {
  final String questId;
  const QuestPage({super.key, required this.questId});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Quête $questId')),
    body: Center(child: Text('Détails de la quête : $questId')),
  );
}
