import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/quest_provider.dart';
import '../../core/providers/service_provider.dart';
import '../../screens/explore/quest_detail_page.dart';
import '../../widgets/common/async_value_widget.dart';
import '../../widgets/common/quest_card.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(favoriteIdsProvider);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes favoris'),
        automaticallyImplyLeading: false,
      ),
      body: favAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erreur : $e")),
        data: (favIds) {
          if (favIds.isEmpty) {
            return const Center(child: Text("Aucun favori."));
          }

          return ListView.builder(
            itemCount: favIds.length,
            itemBuilder: (_, i) {
              final questAsync = ref.watch(questProvider(favIds[i]));
              return AsyncValueWidget(
                value: questAsync,
                dataBuilder:
                    (quest) => QuestCard(
                      quest: quest!,
                      isFavorite: true,
                      onFavoriteToggle:
                          userId == null
                              ? null
                              : () async {
                                await ref
                                    .read(favoriteServiceProvider)
                                    .toggleFavorite(userId, quest.id, true);
                              },
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => QuestDetailPage(
                                  partnerId: quest.partnerId,
                                  questId: quest.id,
                                ),
                          ),
                        );
                      },
                    ),
              );
            },
          );
        },
      ),
    );
  }
}
