// lib/core/state/partner_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_social_quest/core/providers/repository_providers.dart';
import 'package:mvp_social_quest/models/partner.dart';
import 'package:mvp_social_quest/models/quest.dart';

/// Contrôleur pour créer, modifier, supprimer un partner,
/// avec suppression en cascade de ses quests, slots et réductions.
class PartnerController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Rien à initialiser
  }

  /// Crée ou met à jour un partenaire
  Future<void> save(Partner partner) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(partnerRepoProvider).save(partner),
    );
  }

  /// Suppression simple d'un partenaire
  Future<void> delete(String partnerId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(partnerRepoProvider).delete(partnerId),
    );
  }

  /// Suppression en cascade : supprime le partner, ses quests, slots et réductions
  // Ancien début de deleteCascade...
  Future<void> deleteCascade(String partnerId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final firestore = FirebaseFirestore.instance;
      final questRepo = ref.read(questRepoProvider);

      // 1️⃣ Récupère toutes les quests du partner
      final questsSnap =
          await firestore
              .collection('quests')
              .where('partnerId', isEqualTo: partnerId)
              .get();

      for (final qDoc in questsSnap.docs) {
        final quest = Quest.fromJson({'id': qDoc.id, ...?qDoc.data()});
        final questId = quest.id;

        // 2️⃣ Récupère tous les slots globaux de la quest
        final slotQuery =
            await firestore
                .collection('slots')
                .where('questId', isEqualTo: questId)
                .get();

        for (final slotDoc in slotQuery.docs) {
          final slotId = slotDoc.id;

          // 3️⃣ Supprime les réductions globales sous slots/{slotId}/discounts
          final discSnapGlobal =
              await firestore
                  .collection('slots')
                  .doc(slotId)
                  .collection('discounts')
                  .get();
          for (final d in discSnapGlobal.docs) {
            await d.reference.delete();
          }

          // 4️⃣ Supprime les réductions locales sous partners/{partnerId}/slots/{slotId}/discounts
          final discSnapLocal =
              await firestore
                  .collection('partners')
                  .doc(partnerId)
                  .collection('slots')
                  .doc(slotId)
                  .collection('discounts')
                  .get();
          for (final d in discSnapLocal.docs) {
            await d.reference.delete();
          }

          // 5️⃣ Supprime le slot local
          await firestore
              .collection('partners')
              .doc(partnerId)
              .collection('slots')
              .doc(slotId)
              .delete();

          // 6️⃣ Supprime le slot global
          await slotDoc.reference.delete();
        }

        // 7️⃣ Supprime la quest + ses images via QuestRepository
        await questRepo.deleteQuestWithPhotos(quest);
      }

      // 8️⃣ Supprime le partner lui-même
      await firestore.collection('partners').doc(partnerId).delete();
    });
  }
}

/// Provider pour le PartnerController
final partnerControllerProvider =
    AsyncNotifierProvider<PartnerController, void>(PartnerController.new);
