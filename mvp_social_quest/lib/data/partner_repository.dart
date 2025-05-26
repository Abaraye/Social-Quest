import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/partner.dart';
import 'crud_repository.dart';

/// Repository Firestore pour la collection "partners"
class PartnerRepository implements CrudRepository<Partner> {
  PartnerRepository._();
  static final instance = PartnerRepository._();

  /// Référence à la collection Firestore 'partners'
  final CollectionReference<Map<String, dynamic>> _col = FirebaseFirestore
      .instance
      .collection('partners');

  @override
  CollectionReference<Map<String, dynamic>> collection() => _col;

  @override
  Stream<List<Partner>> watchAll() => _col.snapshots().map(
    (snapshot) =>
        snapshot.docs
            .map((doc) => Partner.fromMap(doc.data(), doc.id))
            .toList(),
  );

  @override
  Future<Partner?> fetch(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? Partner.fromMap(doc.data()!, doc.id) : null;
  }

  @override
  Future<void> save(Partner partner) async {
    final col = FirebaseFirestore.instance.collection('partners');
    final map = partner.toJson();

    if (partner.id.isNotEmpty) {
      // Modification : utilise doc(partner.id)
      await col.doc(partner.id).set(map);
    } else {
      // Création : utilise .add()
      await col.add(map);
    }
  }

  @override
  Future<void> delete(String id) => _col.doc(id).delete();

  Future<void> deleteCascade(String partnerId) async {
    final partnerRef = FirebaseFirestore.instance
        .collection('partners')
        .doc(partnerId);

    // Supprimer les quests
    final quests = await partnerRef.collection('quests').get();
    for (final doc in quests.docs) {
      final questId = doc.id;

      // Supprimer les slots de chaque quest
      final slots =
          await partnerRef
              .collection('slots')
              .where('questId', isEqualTo: questId)
              .get();

      for (final slot in slots.docs) {
        final slotId = slot.id;

        // Supprimer les discounts de chaque slot
        final discounts =
            await partnerRef
                .collection('slots')
                .doc(slotId)
                .collection('discounts')
                .get();

        for (final d in discounts.docs) {
          await d.reference.delete();
        }

        await slot.reference.delete(); // supprimer le slot
      }

      await doc.reference.delete(); // supprimer la quest
    }

    // Supprimer le partner lui-même
    await partnerRef.delete();
  }
}
