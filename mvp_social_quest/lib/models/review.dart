// =============================================================
// lib/models/review.dart
// =============================================================
import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle Review : 1 avis = 1 booking.
class Review {
  final String id;
  final String partnerId;
  final String userId;
  final String bookingId;
  final int rating; // 1–5
  final String? comment;
  final Timestamp createdAt;
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

  factory Review.fromMap(Map<String, dynamic> data, String id) => Review(
    id: id,
    partnerId: data['partnerId'] ?? '',
    userId: data['userId'] ?? '',
    bookingId: data['bookingId'] ?? '',
    rating: data['rating'] ?? 0,
    comment: data['comment'],
    createdAt: data['createdAt'] ?? Timestamp.now(),
    reported: data['reported'] ?? false,
  );

  Map<String, dynamic> toMap() => {
    'partnerId': partnerId,
    'userId': userId,
    'bookingId': bookingId,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt,
    'reported': reported,
  };
}
