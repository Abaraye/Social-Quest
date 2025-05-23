import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/quest_provider.dart';
import '../../widgets/common/async_value_widget.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favoriteIdsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes favoris'),
        automaticallyImplyLeading: false,
      ),
      body:
          favIds.isEmpty
              ? const Center(child: Text('Aucun favori.'))
              : ListView.builder(
                itemCount: favIds.length,
                itemBuilder: (_, i) {
                  final quest = ref.watch(questProvider(favIds[i]));
                  return AsyncValueWidget(
                    value: quest,
                    dataBuilder: (q) => ListTile(title: Text(q!.title)),
                  );
                },
              ),
    );
  }
}
