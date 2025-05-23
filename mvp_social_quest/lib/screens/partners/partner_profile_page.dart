import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mvp_social_quest/core/providers/repository_providers.dart';

class PartnerProfilePage extends ConsumerWidget {
  final String partnerId;
  const PartnerProfilePage({super.key, required this.partnerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil du commerce'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () async {
              await ref.read(authRepoProvider).signOut();
              context.go('/welcome');
            },
          ),
        ],
      ),
      body: Center(child: Text('Profil du commerce $partnerId')),
    );
  }
}
