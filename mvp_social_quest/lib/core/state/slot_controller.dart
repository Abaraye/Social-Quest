import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/slot.dart';
import '../providers/repository_providers.dart';

/// Contrôleur d’écriture / suppression d’un Slot
class SlotController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // rien à initialiser
  }

  /// Crée ou met à jour un slot
  Future<void> save(Slot slot) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(slotRepoProvider).save(slot));
  }

  /// Supprime un slot par son identifiant
  Future<void> delete(String slotId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(slotRepoProvider).delete(slotId),
    );
  }

  /// Crée un nouveau slot avec un ID Firestore généré
  Future<String> create({
    required String partnerId,
    required String questId,
    required Slot slot,
  }) async {
    final repo = ref.read(slotRepoProvider);
    final newId = repo.collection().doc().id;
    final newSlot = slot.copyWith(id: newId);
    await save(newSlot); // Appel à save interne
    return newId;
  }
}

final slotControllerProvider = AsyncNotifierProvider<SlotController, void>(
  () => SlotController(),
);
