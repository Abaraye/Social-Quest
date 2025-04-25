// =============================================================
// lib/models/partner.dart  – v2 (photos, ratings, geohash …)
// =============================================================
import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle d’activité / partenaire
///
/// ⚠️  Tous les champs non obligatoires sont optionnels pour conserver la
/// compatibilité ascendante. Les helpers fournissent des valeurs sûres.
class Partner {
  final String id;
  final String name;
  final String description;
  final String address;
  final String category;
  final double latitude;
  final double longitude;

  // ➕ Nouveaux champs
  final List<String> photos; // urls HTTPS (peut être vide)
  final double? avgRating; // moyenne sur 5  (null si aucune review)
  final int? reviewsCount; // nombre d’avis
  final String? geohash; // pour GeoFlutterFire (optionnel)
  final bool active; // soft delete / masquage

  // Slots (sous‑collection → ici cache optionnel)
  final Map<String, List<Map<String, dynamic>>> slots;

  // champ legacy pour affichage reduction max (calculé si absent)
  final int? maxReduction;

  const Partner({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.photos,
    this.avgRating,
    this.reviewsCount,
    this.geohash,
    required this.active,
    required this.slots,
    this.maxReduction,
  });

  // ---------------- JSON / Firestore helpers ----------------

  factory Partner.fromJson(Map<String, dynamic> json) => Partner(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    address: json['address'] ?? '',
    category: json['category'] ?? '',
    latitude: (json['latitude'] ?? 0.0).toDouble(),
    longitude: (json['longitude'] ?? 0.0).toDouble(),
    photos: List<String>.from(json['photos'] ?? []),
    avgRating: (json['avgRating'] as num?)?.toDouble(),
    reviewsCount: json['reviewsCount'],
    geohash: json['geohash'],
    active: json['active'] ?? true,
    slots: {},
    maxReduction: json['maxReduction'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'address': address,
    'category': category,
    'latitude': latitude,
    'longitude': longitude,
    'photos': photos,
    'avgRating': avgRating,
    'reviewsCount': reviewsCount,
    'geohash': geohash,
    'active': active,
    'maxReduction': maxReduction,
  };

  factory Partner.fromMap(Map<String, dynamic> data, String id) {
    final rawSlots = data['slots'] ?? {};
    final parsedSlots = <String, List<Map<String, dynamic>>>{};
    for (final entry in rawSlots.entries) {
      parsedSlots[entry.key] = List<Map<String, dynamic>>.from(
        entry.value ?? [],
      );
    }

    return Partner(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      category: data['category'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      photos: List<String>.from(data['photos'] ?? []),
      avgRating: (data['avgRating'] as num?)?.toDouble(),
      reviewsCount: data['reviewsCount'],
      geohash: data['geohash'],
      active: data['active'] ?? true,
      slots: parsedSlots,
      maxReduction: data['maxReduction'],
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'address': address,
    'category': category,
    'latitude': latitude,
    'longitude': longitude,
    'photos': photos,
    'avgRating': avgRating,
    'reviewsCount': reviewsCount,
    'geohash': geohash,
    'active': active,
    'slots': slots,
    'maxReduction': maxReduction ?? computedMaxReduction,
  };

  // ---------------- Helpers business ----------------

  int get computedMaxReduction {
    int max = 0;
    for (final redList in slots.values) {
      for (final r in redList) {
        final val = r['amount'];
        if (val is int && val > max) max = val;
      }
    }
    return max;
  }

  int get maxReductionDisplay => maxReduction ?? computedMaxReduction;

  bool get hasUpcomingSlot {
    final now = DateTime.now();
    return slots.values.expand((e) => e).any((r) {
      final ts = r['startTime'];
      return ts is Timestamp && ts.toDate().isAfter(now);
    });
  }

  bool get isValid => name.isNotEmpty && description.isNotEmpty;

  @override
  bool operator ==(Object other) => other is Partner && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
