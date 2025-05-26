import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'crud_repository.dart';

class UserRepository implements CrudRepository<AppUser> {
  UserRepository._();
  static final instance = UserRepository._();
  final _fire = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> _col() => _fire.collection('users');

  @override
  CollectionReference<Map<String, dynamic>> collection() => _col();

  @override
  Stream<List<AppUser>> watchAll() =>
      _col().snapshots().map((q) => q.docs.map(_fromDoc).toList());

  @override
  Future<AppUser?> fetch(String id) async {
    final doc = await _col().doc(id).get();
    return doc.exists ? _fromDoc(doc) : null;
  }

  @override
  Future<void> save(AppUser u) =>
      _col().doc(u.id).set(u.toJson(), SetOptions(merge: true));

  @override
  Future<void> delete(String id) => _col().doc(id).delete();

  AppUser _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) =>
      AppUser.fromJson({'id': d.id, ...?d.data()});
}
