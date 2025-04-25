// lib/services/firestore/booking_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/booking.dart';
import 'slot_service.dart';

/// 📆 Gestion des réservations (slots **et** quests)
class BookingService {
  BookingService._();
  static final BookingService instance = BookingService._();

  final _db = FirebaseFirestore.instance;

  /* ---------- Quests ---------- */

  /// ➕ Réserver une **quête**.
  Future<void> bookQuest(String questId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final questSnap = await _db.collection('quests').doc(questId).get();
    if (!questSnap.exists) throw Exception('Quête introuvable');
    final q = questSnap.data()!;

    await _db.collection('bookings').add({
      'userId': user.uid,
      'questId': questId,
      'partnerId': q['partnerId'],
      'priceCents': q['priceCents'] ?? 0,
      'currency': q['currency'] ?? 'EUR',
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  /* ---------- Slots ---------- */

  /// ➕ Réserver un **créneau** (slot).
  Future<void> createSlotBooking({
    required String partnerId,
    required String slotId,
    required DateTime occurrence,
    required Map<String, dynamic> selectedReduction,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final slotRef = _db
        .collection('partners')
        .doc(partnerId)
        .collection('slots')
        .doc(slotId);
    final slotSnap = await slotRef.get();
    if (!slotSnap.exists) throw Exception('Slot introuvable');
    final slot = slotSnap.data()!;

    await _db.collection('bookings').add({
      'userId': user.uid,
      'partnerId': partnerId,
      'slotId': slotId,
      'reductionChosen': selectedReduction,
      'startTime': Timestamp.fromDate(occurrence),
      'priceCents': slot['priceCents'] ?? 0,
      'currency': slot['currency'] ?? 'EUR',
      'taxRate': slot['taxRate'],
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (slot['recurrenceGroupId'] != null) {
      await _deleteSingleOccurrence(partnerId, slotId, occurrence);
    } else {
      await slotRef.update({'reserved': true});
    }
  }

  /* ---------- Suppression ---------- */

  /// 🗑 Supprimer une réservation (slot **ou** quête).
  Future<void> deleteBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).delete();
  }

  /* ---------- Streams partner & user ---------- */

  /// 🔄 Flux temps réel des réservations d’un commerçant.
  Stream<List<Booking>> streamForPartner(String partnerId) => _db
      .collection('bookings')
      .where('partnerId', isEqualTo: partnerId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList());

  /// 🔄 Flux des réservations **futures** de l’utilisateur.
  Stream<List<Booking>> streamUserUpcoming() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .where('startTime', isGreaterThan: Timestamp.now())
        .orderBy('startTime')
        .snapshots()
        .map(
          (s) => s.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList(),
        );
  }

  /// 🔄 Flux **complet** des réservations de l’utilisateur.
  Stream<List<Booking>> streamUserAll() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList(),
        );
  }

  /* ---------- Helpers privés ---------- */

  Future<void> _deleteSingleOccurrence(
    String partnerId,
    String slotId,
    DateTime occurrence,
  ) => _db
      .collection('partners')
      .doc(partnerId)
      .collection('slots')
      .doc(slotId)
      .collection('exceptions')
      .add({'date': Timestamp.fromDate(occurrence)});
}
