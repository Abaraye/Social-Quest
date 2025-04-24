import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/booking.dart';
import 'slot_service.dart';

/// 🔄 Service de gestion des réservations
class BookingService {
  static final _db = FirebaseFirestore.instance;

  /// ➕ Création d'une réservation
  /// - [occurrence] précise la date/heure choisie (utile pour récurrence)
  /// - Pour un slot récurrent, on n'ajoute qu'une exception ; sinon on marque `reserved: true`.
  static Future<void> createBooking({
    required String partnerId,
    required String slotId,
    required DateTime occurrence,
    required Map<String, dynamic> selectedReduction,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    // --- Récupérer le slot parent
    final slotRef = _db
        .collection('partners')
        .doc(partnerId)
        .collection('slots')
        .doc(slotId);
    final slotSnap = await slotRef.get();
    if (!slotSnap.exists) throw Exception('Slot introuvable');
    final slotData = slotSnap.data()!;

    // --- Ajouter la réservation
    await _db.collection('bookings').add({
      'userId': user.uid,
      'partnerId': partnerId,
      'slotId': slotId,
      'reductionChosen': selectedReduction,
      'startTime': Timestamp.fromDate(occurrence),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // --- Gestion récurrence / marque réservé
    if (slotData['recurrenceGroupId'] != null) {
      await SlotService.deleteSingleOccurrence(partnerId, slotId, occurrence);
    } else {
      await slotRef.update({'reserved': true});
    }
  }

  /// 📥 Flux temps réel des réservations d'un commerçant
  static Stream<List<Booking>> streamForPartner(String partnerId) {
    return _db
        .collection('bookings')
        .where('partnerId', isEqualTo: partnerId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList(),
        );
  }

  /// 📅 Requêtage one-shot pour une date précise
  static Future<List<Booking>> getForDay(String partnerId, DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));
    final q =
        await _db
            .collection('bookings')
            .where('partnerId', isEqualTo: partnerId)
            .where(
              'startTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start),
            )
            .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(end))
            .orderBy('startTime')
            .get();
    return q.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList();
  }

  /// 🗑 Suppression par ID
  static Future<void> deleteBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).delete();
  }

  /// 📆 Flux des réservations futures de l'utilisateur
  static Stream<List<Booking>> getUpcomingUserBookings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .where('startTime', isGreaterThan: Timestamp.now())
        .orderBy('startTime')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList(),
        );
  }

  /// 📜 Flux complet des réservations de l'utilisateur
  static Stream<List<Booking>> getUserBookings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList(),
        );
  }

  /// 🛠 Mise à jour partielle
  static Future<void> updateBooking({
    required String bookingId,
    required Map<String, dynamic> updates,
  }) async {
    await _db.collection('bookings').doc(bookingId).update(updates);
  }
}
