import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/partner.dart';

/// Service d’accès et manipulation de données Firestore
/// Centralise la logique de lecture/écriture pour les partenaires, créneaux et réservations
class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Création complète d’un partenaire + créneaux associés
  static Future<void> createPartner({
    required String name,
    required String description,
    required String category,
    required Map<String, List<Map<String, dynamic>>> slots,
    required double latitude,
    required double longitude,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    // 🔍 Calcul de la réduction maximale
    int maxReduction = 0;
    for (final reductions in slots.values) {
      for (final red in reductions) {
        final value = red['amount'] ?? 0;
        if (value > maxReduction) maxReduction = value;
      }
    }

    // 📌 Création du partenaire
    final partnerRef = await _firestore.collection('partners').add({
      'name': name,
      'description': description,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'ownerId': user.uid,
      'maxReduction': maxReduction,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 🧩 Création des créneaux (slots) liés
    for (final entry in slots.entries) {
      final slotLabel = entry.key;
      final reductions = entry.value;
      await partnerRef.collection('slots').add({
        'label': slotLabel, // ⚠️ peut être inutile si on a startTime
        'reductions': reductions,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// 🔹 Stream temps réel des partenaires
  static Stream<List<Partner>> getPartners() {
    return _firestore.collection('partners').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Partner.fromMap(data, doc.id);
      }).toList();
    });
  }

  /// 🔹 Récupération des créneaux pour un partenaire donné
  /// Format attendu : startTime + liste de réductions
  static Future<List<Map<String, dynamic>>> getPartnerSlots(
    String partnerId,
  ) async {
    final snapshot =
        await _firestore
            .collection('partners')
            .doc(partnerId)
            .collection('slots')
            .orderBy('startTime') // 🕒 Important pour l’UI
            .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          final Timestamp? start = data['startTime'];
          final List<dynamic>? reductionsRaw = data['reductions'];

          if (start == null || reductionsRaw == null) return null;

          return {
            'startTime': start,
            'reductions': List<Map<String, dynamic>>.from(reductionsRaw),
          };
        })
        .whereType<Map<String, dynamic>>() // ⛑️ Filtrage null-safe
        .toList();
  }

  /// 🔹 Création d’une réservation
  static Future<void> createBooking({
    required String partnerId,
    required String selectedSlot,
    required String selectedDiscount,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    await _firestore.collection('bookings').add({
      'userId': user.uid,
      'partnerId': partnerId,
      'selectedSlot': selectedSlot,
      'selectedDiscount': selectedDiscount,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
