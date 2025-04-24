// lib/models/partner/partner_reviews.dart

/// ⭐️ Avis : note moyenne et nombre d’avis
class PartnerReviews {
  final double? avgRating;
  final int? reviewsCount;

  const PartnerReviews({this.avgRating, this.reviewsCount});

  factory PartnerReviews.fromMap(Map<String, dynamic> data) {
    return PartnerReviews(
      avgRating: (data['avgRating'] as num?)?.toDouble(),
      reviewsCount: data['reviewsCount'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
    'avgRating': avgRating,
    'reviewsCount': reviewsCount,
  };
}
