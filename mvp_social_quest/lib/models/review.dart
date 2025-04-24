// lib/models/review.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// ⭐️ Modèle d’un avis (Review) lié à une réservation.
class Review {
  final String id;
  final String partnerId;
  final String userId;
  final String bookingId;
  final int rating; // 1..5
  final String? comment;
  final DateTime createdAt;
  final bool reported;

  Review({
    required this.id,
    required this.partnerId,
    required this.userId,
    required this.bookingId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.reported = false,
  });

  /// Construit depuis Firestore.
  factory Review.fromMap(Map<String, dynamic> data, String id) {
    final ts = data['createdAt'] as Timestamp?;
    return Review(
      id: id,
      partnerId: data['partnerId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      bookingId: data['bookingId'] as String? ?? '',
      rating: data['rating'] as int? ?? 0,
      comment: data['comment'] as String?,
      createdAt: ts?.toDate() ?? DateTime.now(),
      reported: data['reported'] as bool? ?? false,
    );
  }

  /// Exporte en Map pour Firestore.
  Map<String, dynamic> toMap() => {
    'partnerId': partnerId,
    'userId': userId,
    'bookingId': bookingId,
    'rating': rating,
    'comment': comment,
    'createdAt': Timestamp.fromDate(createdAt),
    'reported': reported,
  };

  @override
  String toString() => 'Review($id, partner=$partnerId, rating=$rating)';
}
