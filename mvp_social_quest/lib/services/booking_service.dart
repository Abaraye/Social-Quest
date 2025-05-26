import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvp_social_quest/models/booking.dart';

class BookingService {
  final FirebaseFirestore _db;

  BookingService(this._db);

  Future<String> reserveBooking({
    required String userId,
    required String partnerId,
    required String questId,
    required String slotId,
    required DateTime startTime,
    required int peopleCount,
    required int priceCentsPerPerson,
    String currency = 'EUR',
  }) async {
    final now = DateTime.now();
    final totalCents = priceCentsPerPerson * peopleCount;

    final bookingRef = _db.collection('bookings').doc();
    final booking = Booking(
      id: bookingRef.id,
      userId: userId,
      partnerId: partnerId,
      questId: questId,
      slotId: slotId,
      peopleCount: peopleCount,
      totalPriceCents: totalCents,
      currency: currency,
      status: 'confirmed',
      startTime: startTime,
      createdAt: now,
      updatedAt: now,
    );

    await bookingRef.set(booking.toJson());
    return booking.id;
  }

  Future<bool> cancelBookingWithConfirmation(
    BuildContext context,
    String bookingId, {
    bool useRootNavigator = false, // ✅ permet de choisir selon contexte
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      useRootNavigator: useRootNavigator,
      builder:
          (_) => AlertDialog(
            title: const Text("Êtes-vous sûr ?"),
            content: const Text("Cette action est irréversible."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Non"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Oui, annuler"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await cancelBooking(bookingId);
      return true;
    }
    return false;
  }

  Future<void> cancelBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).delete();
  }
}
