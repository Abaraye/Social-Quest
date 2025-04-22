// =============================================================
// lib/services/firestore/stats_service.dart – v2.1
// =============================================================
// 📊 Donne accès aux statistiques clés pour le dashboard commerçant
// ✅ Ajout du taux de conversion & taux d’annulation (patch champ manquant)
// -------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerStats {
  final Map<DateTime, int> bookingsByDay;
  final double fillRate;
  final double avgRating;

  PartnerStats({
    required this.bookingsByDay,
    required this.fillRate,
    required this.avgRating,
  });
}

class StatsService {
  static final _firestore = FirebaseFirestore.instance;

  /// 📈 Stats principales pour le tableau de bord
  static Future<PartnerStats> getPartnerStats(String partnerId) async {
    final now = DateTime.now();
    final startWeek = DateTime(now.year, now.month, now.day - 6);

    final bookingsSnap =
        await _firestore
            .collection('bookings')
            .where('partnerId', isEqualTo: partnerId)
            .where('startTime', isGreaterThan: Timestamp.fromDate(startWeek))
            .get();

    final Map<DateTime, int> bookingsByDay = {};
    for (final doc in bookingsSnap.docs) {
      final date = (doc['startTime'] as Timestamp).toDate();
      final day = DateTime(date.year, date.month, date.day);
      bookingsByDay.update(day, (v) => v + 1, ifAbsent: () => 1);
    }

    final reviewsSnap =
        await _firestore
            .collection('partners')
            .doc(partnerId)
            .collection('reviews')
            .get();

    double avgRating = 0;
    if (reviewsSnap.docs.isNotEmpty) {
      final total = reviewsSnap.docs.fold<int>(
        0,
        (sum, doc) => sum + (doc['rating'] as int),
      );
      avgRating = total / reviewsSnap.docs.length;
    }

    final fillRate = await getFillRate(partnerId);

    return PartnerStats(
      bookingsByDay: bookingsByDay,
      fillRate: fillRate,
      avgRating: avgRating,
    );
  }

  /// 📊 Calcul du taux de remplissage (réservations / slots à venir)
  static Future<double> getFillRate(String partnerId) async {
    final now = Timestamp.now();
    final bookingsSnap =
        await _firestore
            .collection('bookings')
            .where('partnerId', isEqualTo: partnerId)
            .where('startTime', isGreaterThan: now)
            .get();

    final slotsSnap =
        await _firestore
            .collection('partners')
            .doc(partnerId)
            .collection('slots')
            .where('startTime', isGreaterThan: now)
            .get();

    if (slotsSnap.docs.isEmpty) return 0;

    return bookingsSnap.docs.length / slotsSnap.docs.length;
  }

  /// 🎯 Taux de conversion : nombre de réservations / nombre de slots
  static Future<double> getConversionRate(String partnerId) async {
    final bookings =
        await _firestore
            .collection('bookings')
            .where('partnerId', isEqualTo: partnerId)
            .get();

    final slots =
        await _firestore
            .collection('partners')
            .doc(partnerId)
            .collection('slots')
            .get();

    if (slots.docs.isEmpty) return 0;

    return bookings.docs.length / slots.docs.length;
  }

  /// 🚫 Taux d’annulation = bookings avec champ "cancelled": true
  static Future<double> getCancelRate(String partnerId) async {
    final all =
        await _firestore
            .collection('bookings')
            .where('partnerId', isEqualTo: partnerId)
            .get();

    final cancelled = all.docs.where(
      (d) => d.data().containsKey('cancelled') && d['cancelled'] == true,
    );

    if (all.docs.isEmpty) return 0;

    return cancelled.length / all.docs.length;
  }
}
