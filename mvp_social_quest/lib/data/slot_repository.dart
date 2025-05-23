import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/slot.dart';
import 'crud_repository.dart';

class SlotRepository implements CrudRepository<Slot> {
  SlotRepository._();
  static final instance = SlotRepository._();
  final _col = FirebaseFirestore.instance.collection('slots');

  @override
  CollectionReference<Map<String, dynamic>> collection() => _col;

  @override
  Stream<List<Slot>> watchAll() =>
      _col.snapshots().map((q) => q.docs.map(_f).toList());

  @override
  Future<Slot?> fetch(String id) async {
    final d = await _col.doc(id).get();
    return d.exists ? _f(d) : null;
  }

  @override
  Future<void> save(Slot s) =>
      _col.doc(s.id).set(s.toJson(), SetOptions(merge: true));

  @override
  Future<void> delete(String id) => _col.doc(id).delete();

  Slot _f(DocumentSnapshot<Map<String, dynamic>> d) =>
      Slot.fromJson({'id': d.id, ...?d.data()});
}
