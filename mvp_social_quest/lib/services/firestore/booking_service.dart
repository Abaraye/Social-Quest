// lib/services/firestore/booking_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/booking.dart';

/// 🔄 Service de gestion des réservations Firebase (collection `/bookings`)
class BookingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ➕ Crée une nouvelle réservation utilisateur
  /// Récupère le `startTime` directement depuis le créneau (`slotId`) sélectionné
  static Future<void> createBooking({
    required String partnerId,
    required String slotId,
    required Map<String, dynamic> selectedReduction,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final slotDoc =
        await _firestore
            .collection('partners')
            .doc(partnerId)
            .collection('slots')
            .doc(slotId)
            .get();

    if (!slotDoc.exists) {
      throw Exception('Créneau introuvable pour cette activité.');
    }

    final startTime = slotDoc.data()?['startTime'] as Timestamp?;
    if (startTime == null) {
      throw Exception('Le créneau sélectionné n’a pas de startTime valide.');
    }

    await _firestore.collection('bookings').add({
      'userId': user.uid,
      'partnerId': partnerId,
      'slotId': slotId,
      'reductionChosen': selectedReduction,
      'startTime': startTime,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 📥 Récupère toutes les réservations de l’utilisateur connecté
  static Stream<List<Booking>> getUserBookings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          print('❌ Erreur Firestore - getUserBookings: $error');
        })
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Booking.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  /// 📆 Récupère uniquement les réservations futures
  static Stream<List<Booking>> getUpcomingUserBookings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .orderBy('startTime')
        .where('startTime', isGreaterThan: Timestamp.now())
        .snapshots()
        .handleError((error) {
          print('❌ Erreur Firestore - getUpcomingUserBookings: $error');
        })
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Booking.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  /// 🗑 Supprime une réservation
  static Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).delete();
  }

  /// 🛠 Met à jour un ou plusieurs champs d’une réservation
  static Future<void> updateBooking({
    required String bookingId,
    required Map<String, dynamic> updates,
  }) async {
    await _firestore.collection('bookings').doc(bookingId).update(updates);
  }
}
