// lib/services/firestore/booking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/booking.dart';

/// 🔄 Service de gestion des réservations Firebase (collection `/bookings`)
class BookingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ➕ Crée une nouvelle réservation utilisateur avec startTime extrait du slot
  static Future<void> createBooking({
    required String partnerId,
    required String slotId,
    required Map<String, dynamic> selectedReduction,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    // ⏳ Récupération du startTime à partir du slot
    final slotSnapshot =
        await _firestore
            .collection('partners')
            .doc(partnerId)
            .collection('slots')
            .doc(slotId)
            .get();

    if (!slotSnapshot.exists) {
      throw Exception('Le créneau sélectionné est introuvable.');
    }

    final startTime = slotSnapshot.data()?['startTime'] as Timestamp?;

    if (startTime == null) {
      throw Exception('Le créneau ne contient pas de startTime valide.');
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

  /// 📥 Récupère les réservations utilisateur sous forme de `Booking`
  static Stream<List<Booking>> getUserBookings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Booking.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  /// ⏳ Récupère uniquement les réservations à venir
  static Stream<List<Booking>> getUpcomingUserBookings() {
    final now = Timestamp.now();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .where('startTime', isGreaterThan: now)
        .orderBy('startTime')
        .snapshots()
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

  /// 🛠 Met à jour un champ de la réservation (optionnel)
  static Future<void> updateBooking({
    required String bookingId,
    required Map<String, dynamic> updates,
  }) async {
    await _firestore.collection('bookings').doc(bookingId).update(updates);
  }
}
