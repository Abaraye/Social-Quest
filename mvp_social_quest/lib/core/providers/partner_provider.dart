import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_social_quest/models/quest.dart';
import 'package:mvp_social_quest/models/slot.dart';
import '../../models/partner.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

/// Flux des partenaires du commerçant connecté
final partnerListProvider = StreamProvider<List<Partner>>((ref) {
  final auth = ref.watch(authProvider).value;
  final uid = auth?.uid;
  if (uid == null) return const Stream.empty();

  return ref
      .read(partnerRepoProvider)
      .watchAll()
      .map((list) => list.where((p) => p.ownerId == uid).toList());
});

/// Accès ponctuel par ID
final partnerProvider = StreamProvider.family<Partner?, String>((ref, id) {
  return ref
      .watch(partnerRepoProvider)
      .watchAll()
      .map((list) => list.where((p) => p.id == id).firstOrNull);
});

/// Toutes les quests pour un partner
final questsOfPartnerProvider = StreamProvider.family<List<Quest>, String>((
  ref,
  partnerId,
) {
  return ref
      .read(questRepoProvider)
      .watchAll()
      .map((list) => list.where((q) => q.partnerId == partnerId).toList());
});

/// Tous les slots pour une quest
final slotsOfQuestProvider = StreamProvider.family<List<Slot>, String>((
  ref,
  questId,
) {
  return ref.watch(slotRepoProvider).watchAll().map((list) {
    final filtered = list.where((s) => s.questId == questId).toList();
    print('[slotsOfQuestProvider] pour $questId → ${filtered.length} slots');
    return filtered;
  });
});
