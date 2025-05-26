// lib/core/providers/quest_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_social_quest/models/quest.dart';
import 'repository_providers.dart';

/// Liste de toutes les quests
final questListProvider = StreamProvider<List<Quest>>(
  (ref) => ref.watch(questRepoProvider).watchAll(),
);

/// Récupère une quest par son ID
final questProvider = FutureProvider.family<Quest?, String>(
  (ref, id) => ref.watch(questRepoProvider).fetch(id),
);

/// Liste des quests pour un partner (family) filtrée sur client side
final questsOfPartnerProvider = StreamProvider.family<List<Quest>, String>(
  (ref, partnerId) => ref
      .watch(questRepoProvider)
      .watchAll()
      .map((all) => all.where((q) => q.partnerId == partnerId).toList()),
);
