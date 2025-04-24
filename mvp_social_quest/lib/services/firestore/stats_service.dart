import 'package:cloud_firestore/cloud_firestore.dart';

/// 📊 Conteneur des statistiques principales pour le dashboard commerçant.
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

/// 👷 Service d’accès aux statistiques Firestore.
class StatsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Récupère :
  ///  • le nombre de réservations par jour sur la dernière semaine,
  ///  • le taux de remplissage (futurs),
  ///  • la note moyenne.
  static Future<PartnerStats> getPartnerStats(String partnerId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));

    // --- 1) Réservations sur la dernière semaine ---
    final bookingSnap =
        await _firestore
            .collection('bookings')
            .where('partnerId', isEqualTo: partnerId)
            .where(
              'startTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo),
            )
            .get();

    final Map<DateTime, int> bookingsByDay = {};
    for (final doc in bookingSnap.docs) {
      final ts = (doc['startTime'] as Timestamp).toDate();
      final day = DateTime(ts.year, ts.month, ts.day);
      bookingsByDay[day] = (bookingsByDay[day] ?? 0) + 1;
    }

    // --- 2) Note moyenne des avis ---
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

    // --- 3) Taux de remplissage futur ---
    final fillRate = await getFillRate(partnerId);

    return PartnerStats(
      bookingsByDay: bookingsByDay,
      fillRate: fillRate,
      avgRating: avgRating,
    );
  }

  /// Calcul du taux de remplissage = (réservations futures) / (slots futurs).
  static Future<double> getFillRate(String partnerId) async {
    final nowTs = Timestamp.now();

    final bookingsSnap =
        await _firestore
            .collection('bookings')
            .where('partnerId', isEqualTo: partnerId)
            .where('startTime', isGreaterThan: nowTs)
            .get();

    final slotsSnap =
        await _firestore
            .collection('partners')
            .doc(partnerId)
            .collection('slots')
            .where('startTime', isGreaterThan: nowTs)
            .get();

    final totalSlots = slotsSnap.docs.length;
    if (totalSlots == 0) return 0.0;
    return bookingsSnap.docs.length / totalSlots;
  }

  /// Taux de conversion global = réservations / total de slots (toutes dates).
  static Future<double> getConversionRate(String partnerId) async {
    final bookingsSnap =
        await _firestore
            .collection('bookings')
            .where('partnerId', isEqualTo: partnerId)
            .get();

    final slotsSnap =
        await _firestore
            .collection('partners')
            .doc(partnerId)
            .collection('slots')
            .get();

    final totalSlots = slotsSnap.docs.length;
    if (totalSlots == 0) return 0.0;
    return bookingsSnap.docs.length / totalSlots;
  }

  /// Taux d’annulation = nombre de bookings avec `cancelled == true`.
  static Future<double> getCancelRate(String partnerId) async {
    final allSnap =
        await _firestore
            .collection('bookings')
            .where('partnerId', isEqualTo: partnerId)
            .get();

    final cancelledCount =
        allSnap.docs
            .where((d) => (d.data()['cancelled'] ?? false) == true)
            .length;

    if (allSnap.docs.isEmpty) return 0.0;
    return cancelledCount / allSnap.docs.length;
  }
}
