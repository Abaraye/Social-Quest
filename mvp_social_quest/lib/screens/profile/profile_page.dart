import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mvp_social_quest/core/providers/repository_providers.dart';
import 'package:mvp_social_quest/models/user.dart';
import '../../core/providers/user_provider.dart';
import '../../widgets/common/async_value_widget.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
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
      body: AsyncValueWidget(
        value: user,
        dataBuilder:
            (AppUser? u) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u?.name ?? 'Utilisateur',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(u?.email ?? ''),
                  const SizedBox(height: 24),
                  Text('Type : ${u?.type ?? 'user'}'),
                ],
              ),
            ),
      ),
    );
  }
}
