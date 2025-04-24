import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/review.dart';

/// Gestion des avis (dans sous-collection `/partners/{pid}/reviews`).
class PartnerReviewService {
  static final _firestore = FirebaseFirestore.instance;

  Stream<List<Review>> streamReviews(String partnerId) {
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

  Future<void> addReview(String partnerId, Review review) => _firestore
      .collection('partners')
      .doc(partnerId)
      .collection('reviews')
      .doc(review.id)
      .set(review.toMap());
}
