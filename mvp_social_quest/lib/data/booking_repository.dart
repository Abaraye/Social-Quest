import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';
import 'crud_repository.dart';

class BookingRepository implements CrudRepository<Booking> {
  BookingRepository._();
  static final instance = BookingRepository._();
  final _col = FirebaseFirestore.instance.collection('bookings');

  @override
  CollectionReference<Map<String, dynamic>> collection() => _col;

  @override
  Stream<List<Booking>> watchAll() =>
      _col.snapshots().map((q) => q.docs.map(_f).toList());

  @override
  Future<Booking?> fetch(String id) async {
    final d = await _col.doc(id).get();
    return d.exists ? _f(d) : null;
  }

  Future<List<Booking>> fetchByPartnerId(String partnerId) async {
    final snap =
        await _col
            .where('partnerId', isEqualTo: partnerId)
            .orderBy('startTime')
            .get();

    return snap.docs.map((doc) => Booking.fromDoc(doc)).toList();
  }

  @override
  Future<void> save(Booking b) =>
      _col.doc(b.id).set(b.toJson(), SetOptions(merge: true));

  @override
  Future<void> delete(String id) => _col.doc(id).delete();

  Booking _f(DocumentSnapshot<Map<String, dynamic>> d) =>
      Booking.fromJson({'id': d.id, ...?d.data()});
}
