import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/slot.dart';
import 'repository_providers.dart';

final slotListProvider = StreamProvider.family.autoDispose<List<Slot>, String>((
  ref,
  questId,
) {
  final db = FirebaseFirestore.instance;

  return db
      .collectionGroup('slots') // 🔥 permet d’éviter de spécifier le partnerId
      .where('questId', isEqualTo: questId)
      .orderBy('startTime')
      .snapshots()
      .map(
        (snap) =>
            snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Slot.fromMap(data);
            }).toList(),
      );
});

final slotProvider = FutureProvider.family<Slot?, String>(
  (ref, id) => ref.watch(slotRepoProvider).fetch(id),
);
