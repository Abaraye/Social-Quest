import 'package:flutter/material.dart';

class PartnerOnboardingPage extends StatelessWidget {
  const PartnerOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('On-boarding commerçant')),
    body: const Center(child: Text('Étapes pour créer votre commerce.')),
  );
}
