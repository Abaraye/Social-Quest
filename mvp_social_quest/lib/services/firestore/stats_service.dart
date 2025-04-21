// =============================================================
// lib/services/firestore/stats_service.dart  – v2.1
// =============================================================
// • Compatible avec l’index composite existant :
//   (partnerId ASC, startTime ASC, __name__ ASC)
// • Rassemble les réservations des 7 derniers jours
// • Calcule un fill‑rate (provisoire) et la note moyenne
// ------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Objet renvoyé à la couche UI (dashboard commerçant)
class PartnerStats {
  final Map<DateTime, int> bookingsByDay; // clé = jour (00:00)
  final double fillRate; // 0.0 – 1.0
  final double avgRating; // 0.0 – 5.0

  PartnerStats({
    required this.bookingsByDay,
    required this.fillRate,
    required this.avgRating,
  });
}

class StatsService {
  static final _fs = FirebaseFirestore.instance;

  /// Retourne :
  ///   • `bookingsByDay`   : Nb de réservations par jour (7 derniers jours)
  ///   • `fillRate`        : Taux de remplissage global
  ///   • `avgRating`       : Note moyenne (collection `reviews`)
  static Future<PartnerStats> getPartnerStats(String partnerId) async {
    //-------------------- 1) Réservations dernières 24 h x 7 ------------------
    final today = DateTime.now();
    final startRange = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 6));

    late QuerySnapshot<Map<String, dynamic>> bookingsSnap;
    try {
      bookingsSnap =
          await _fs
              .collection('bookings')
              .where('partnerId', isEqualTo: partnerId)
              .where(
                'startTime',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startRange),
              )
              .orderBy('startTime')
              .orderBy(FieldPath.documentId)
              .get();
    } on FirebaseException catch (e) {
      // 👇 Capture propre du message + lien Firestore
      debugPrint('🔥 Firestore index error: ${e.message}');
      rethrow;
    }

    // Agrégation “jour => compteur”
    final Map<DateTime, int> byDay = {};
    for (final b in bookingsSnap.docs) {
      final ts = (b['startTime'] as Timestamp).toDate();
      final dayKey = DateTime(ts.year, ts.month, ts.day);
      byDay[dayKey] = (byDay[dayKey] ?? 0) + 1;
    }

    //-------------------- 2) Fill‑rate (placeholder) ---------------------------
    const totalPlaces = 100; // TODO : logique réelle
    final reserved = bookingsSnap.docs.length;
    final fillRate = totalPlaces == 0 ? 0.0 : reserved / totalPlaces;

    //-------------------- 3) Note moyenne --------------------------------------
    final reviewsSnap =
        await _fs
            .collection('partners')
            .doc(partnerId)
            .collection('reviews')
            .get();

    double avg = 0.0;
    if (reviewsSnap.docs.isNotEmpty) {
      final total = reviewsSnap.docs.fold<double>(
        0.0,
        (sum, r) => sum + (r['rating'] as num).toDouble(),
      );
      avg = total / reviewsSnap.docs.length;
    }

    return PartnerStats(
      bookingsByDay: byDay,
      fillRate: fillRate,
      avgRating: avg,
    );
  }
}
