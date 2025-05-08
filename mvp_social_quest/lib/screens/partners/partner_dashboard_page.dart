import 'package:flutter/material.dart';

class PartnerDashboardPage extends StatelessWidget {
  const PartnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Dashboard commerçant')),
    body: const Center(child: Text('Statistiques et gestion rapides.')),
  );
}
