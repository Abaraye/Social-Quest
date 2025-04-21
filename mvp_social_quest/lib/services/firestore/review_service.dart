// =============================================================
// lib/services/firestore/review_service.dart
// =============================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/review.dart';

/// Service Firestore pour la gestion des avis.
class ReviewService {
  static final _firestore = FirebaseFirestore.instance;

  /// Stream temps réel des avis d’un partenaire (tri récents).
  static Stream<List<Review>> streamPartnerReviews(String partnerId) {
    return _firestore
        .collection('partners')
        .doc(partnerId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Review.fromMap(d.data(), d.id)).toList(),
        );
  }

  /// Ajoute un avis (1 avis par booking côté règles + CF).
  static Future<void> addReview({
    required String partnerId,
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final docRef =
        _firestore
            .collection('partners')
            .doc(partnerId)
            .collection('reviews')
            .doc();

    await docRef.set({
      'partnerId': partnerId,
      'userId': user.uid,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
      'reported': false,
    });
  }

  /// Signale un avis inapproprié (flag).
  static Future<void> reportReview(String partnerId, String reviewId) async {
    await _firestore
        .collection('partners')
        .doc(partnerId)
        .collection('reviews')
        .doc(reviewId)
        .update({'reported': true});
  }
}
