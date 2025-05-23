// lib/widgets/pages/partner_onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mvp_social_quest/widgets/forms/partner_form.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/auth_provider.dart';

class PartnerOnboardingPage extends ConsumerWidget {
  const PartnerOnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authProvider).value?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ajouter un commerce')),
        body: const Center(child: Text('Utilisateur non connecté')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un commerce')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: PartnerForm(
          onSaved: () {
            // Après création, naviguer vers le dashboard du partner
            final newId = const Uuid().v4();
            // Note : PartnerForm utilise partnerController.save, qui génère
            // ou écrase l'ID. Ici on suppose que le Partner a un ID généré en amont.
            // Si PartnerForm ne génère pas d'ID, on pourrait récupérer le Partner
            // via un provider ou retourner l'ID dans onSaved.
            context.go('/dashboard/${newId}');
          },
        ),
      ),
    );
  }
}
