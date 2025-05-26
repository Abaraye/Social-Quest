import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ AJOUTÉ
import 'package:mvp_social_quest/screens/explore/quest_detail_page.dart';
import '../../core/providers/quest_provider.dart';
import '../../core/providers/user_provider.dart'; // ✅ AJOUTÉ
import '../../core/providers/service_provider.dart'; // ✅ AJOUTÉ
import '../../models/quest_category.dart';
import '../../widgets/common/async_value_widget.dart';
import '../../widgets/common/quest_card.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  String searchQuery = '';
  QuestCategory? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final quests = ref.watch(questListProvider);
    final favoriteValue = ref.watch(favoriteIdsProvider);
    final favoriteIds = favoriteValue.maybeWhen(
      data: (list) => list,
      orElse: () => [],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        surfaceTintColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une activité...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged:
                  (value) => setState(() => searchQuery = value.toLowerCase()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<QuestCategory?>(
              isExpanded: true,
              value: selectedCategory,
              hint: const Text('Toutes les catégories'),
              onChanged: (value) => setState(() => selectedCategory = value),
              items: [
                const DropdownMenuItem<QuestCategory?>(
                  value: null,
                  child: Text('Toutes les catégories'),
                ),
                ...QuestCategory.values.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat.label));
                }).toList(),
              ],
            ),
          ),
          Expanded(
            child: AsyncValueWidget(
              value: quests,
              dataBuilder: (list) {
                final filtered =
                    list.where((q) {
                      final matchesSearch = q.title.toLowerCase().contains(
                        searchQuery,
                      );
                      final matchesCategory =
                          selectedCategory == null ||
                          q.category == selectedCategory;
                      return matchesSearch && matchesCategory;
                    }).toList();

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final quest = filtered[i];
                    final isFav = favoriteIds.contains(quest.id); // ✅
                    final userId = FirebaseAuth.instance.currentUser?.uid; // ✅

                    return QuestCard(
                      quest: quest,
                      isFavorite: isFav,
                      onFavoriteToggle:
                          userId == null
                              ? null
                              : () async {
                                await ref
                                    .read(favoriteServiceProvider)
                                    .toggleFavorite(userId, quest.id, isFav);
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
