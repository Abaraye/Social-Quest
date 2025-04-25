import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvp_social_quest/models/quest.dart';

/// 🔎 Gestion des quêtes (CRUD + streams)
class QuestService {
  QuestService._();
  static final QuestService instance = QuestService._();

  final _col = FirebaseFirestore.instance.collection('quests');

  /* ---------- Streams ---------- */

  /// Flux de **toutes** les quêtes actives (home-feed).
  Stream<List<Quest>> streamAll() => _col
      .where('isActive', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(_toList);

  /// Flux de toutes les quêtes d’un commerçant.
  Stream<List<Quest>> streamByPartner(String partnerId) => _col
      .where('partnerId', isEqualTo: partnerId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(_toList);

  /// Flux d’une **quête unique** (détail).
  Stream<Quest> streamById(String id) =>
      _col.doc(id).snapshots().map((d) => Quest.fromDoc(d));

  /* ---------- CRUD ---------- */

  Future<Quest> create(Quest q) async {
    final now = FieldValue.serverTimestamp();
    final ref = await _col.add({
      ...q.toJson(),
      'createdAt': now,
      'updatedAt': now,
    });
    final doc = await ref.get();
    return Quest.fromDoc(doc);
  }

  Future<void> update(String id, Map<String, dynamic> data) =>
      _col.doc(id).update({...data, 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> delete(String id) => _col.doc(id).delete();

  Future<Quest?> fetch(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? Quest.fromDoc(doc) : null;
  }

  /* ---------- Helpers ---------- */

  List<Quest> _toList(QuerySnapshot<Map<String, dynamic>> snap) =>
      snap.docs.map(Quest.fromDoc).toList();
}
