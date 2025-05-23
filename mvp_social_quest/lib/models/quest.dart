import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvp_social_quest/core/utils/date_mapper.dart';

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

  /* ---------- JSON ---------- */

  /* ---------- JSON Firestore ---------- */
  factory Quest.fromJson(Map<String, dynamic> json) => Quest(
    id: json['id'] as String,
    partnerId: json['partnerId'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    priceCents: json['priceCents'] as int,
    currency: json['currency'] as String,
    photos: List<String>.from(json['photos'] ?? const []),
    capacity: json['capacity'] ?? 0,
    bookedCount: json['bookedCount'] ?? 0,
    startsAt: toDate(json['startsAt']),
    endsAt: toDate(json['endsAt']),
    avgRating: (json['avgRating'] ?? 0).toDouble(),
    reviewsCount: json['reviewsCount'] ?? 0,
    isActive: json['isActive'] ?? true,
    createdAt: toDate(json['createdAt'])!,
    updatedAt: toDate(json['updatedAt'])!,
  );

  Map<String, dynamic> toJson() => {
    'partnerId': partnerId,
    'title': title,
    'description': description,
    'priceCents': priceCents,
    'currency': currency,
    'photos': photos,
    'capacity': capacity,
    'bookedCount': bookedCount,
    'startsAt': toTimestamp(startsAt),
    'endsAt': toTimestamp(endsAt),
    'avgRating': avgRating,
    'reviewsCount': reviewsCount,
    'isActive': isActive,
    'createdAt': toTimestamp(createdAt),
    'updatedAt': toTimestamp(updatedAt),
  };
}

extension QuestCopyWith on Quest {
  Quest copyWith({
    String? id,
    String? partnerId,
    String? title,
    String? description,
    int? priceCents,
    String? currency,
    List<String>? photos,
    int? capacity,
    int? bookedCount,
    DateTime? startsAt,
    DateTime? endsAt,
    double? avgRating,
    int? reviewsCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Quest(
      id: id ?? this.id,
      partnerId: partnerId ?? this.partnerId,
      title: title ?? this.title,
      description: description ?? this.description,
      priceCents: priceCents ?? this.priceCents,
      currency: currency ?? this.currency,
      photos: photos ?? this.photos,
      capacity: capacity ?? this.capacity,
      bookedCount: bookedCount ?? this.bookedCount,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      avgRating: avgRating ?? this.avgRating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
