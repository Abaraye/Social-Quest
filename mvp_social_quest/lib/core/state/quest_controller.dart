// lib/core/state/quest_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_social_quest/core/providers/repository_providers.dart';
import 'package:mvp_social_quest/models/quest.dart';

class QuestController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Rien à initialiser
  }

  /// Crée ou met à jour une quest
  Future<void> save(Quest quest) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(questRepoProvider).save(quest),
    );
  }

  /// Suppression simple d'une quest
  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(questRepoProvider).delete(id),
    );
  }

  /// Suppression en cascade : supprime la quest, ses slots et les réductions associées
  Future<void> deleteCascade({
    required String partnerId,
    required String questId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final firestore = FirebaseFirestore.instance;

      // 1️⃣ Récupère tous les slots globaux liés à la quest
      final slotQuery =
          await firestore
              .collection('slots')
              .where('questId', isEqualTo: questId)
              .get();

      for (final slotDoc in slotQuery.docs) {
        final slotId = slotDoc.id;

        // 2️⃣ Supprime les réductions globales sous slots/{slotId}/discounts
        final discSnapGlobal =
            await firestore
                .collection('slots')
                .doc(slotId)
                .collection('discounts')
                .get();
        for (final d in discSnapGlobal.docs) {
          await d.reference.delete();
        }

        // 3️⃣ (Optionnel) Supprime le slot local sous partners/{partnerId}/slots
        await firestore
            .collection('partners')
            .doc(partnerId)
            .collection('slots')
            .doc(slotId)
            .delete();

        // 4️⃣ Supprime le slot global
        await slotDoc.reference.delete();
      }

      // 5️⃣ Enfin supprime la quest elle-même
      await firestore.collection('quests').doc(questId).delete();
    });
  }
}

// Provider pour le controller
final questControllerProvider = AsyncNotifierProvider<QuestController, void>(
  QuestController.new,
);
