import 'package:cloud_firestore/cloud_firestore.dart';

class Quest {
  Quest({
    required this.id,
    required this.partnerId,
    required this.title,
    required this.description,
    required this.priceCents,
    required this.currency,
    this.photos = const [],
    this.capacity = 0,
    this.bookedCount = 0,
    this.startsAt,
    this.endsAt,
    this.avgRating = 0,
    this.reviewsCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String partnerId;
  final String title;
  final String description;
  final int priceCents;
  final String currency;
  final List<String> photos;

  final int capacity;
  final int bookedCount;

  final DateTime? startsAt;
  final DateTime? endsAt;

  final double avgRating;
  final int reviewsCount;
  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;

  /* ---------- Serialization ---------- */

  factory Quest.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Quest(
      id: doc.id,
      partnerId: d['partnerId'],
      title: d['title'],
      description: d['description'],
      priceCents: d['priceCents'],
      currency: d['currency'],
      photos: List<String>.from(d['photos'] ?? []),
      capacity: d['capacity'] ?? 0,
      bookedCount: d['bookedCount'] ?? 0,
      startsAt: (d['startsAt'] as Timestamp?)?.toDate(),
      endsAt: (d['endsAt'] as Timestamp?)?.toDate(),
      avgRating: (d['avgRating'] ?? 0).toDouble(),
      reviewsCount: d['reviewsCount'] ?? 0,
      isActive: d['isActive'] ?? true,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'partnerId': partnerId,
    'title': title,
    'description': description,
    'priceCents': priceCents,
    'currency': currency,
    'photos': photos,
    'capacity': capacity,
    'bookedCount': bookedCount,
    'startsAt': startsAt,
    'endsAt': endsAt,
    'avgRating': avgRating,
    'reviewsCount': reviewsCount,
    'isActive': isActive,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
