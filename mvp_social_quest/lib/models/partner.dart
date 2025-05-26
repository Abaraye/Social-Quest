// =============================================================
// lib/models/partner.dart  – v3 (fields ownerId, phone ajoutés)
// =============================================================
import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle d’activité / partenaire
///
/// ⚠️  Tous les champs non obligatoires sont optionnels pour conserver la
/// compatibilité ascendante.
class Partner {
  final String id;
  final String name;
  final String description;
  final String address;
  final String category;
  final double latitude;
  final double longitude;

  // ➕ Nouveaux champs propriétaires
  final String ownerId; // UID du propriétaire marchand
  final String phone; // Téléphone du commerce

  // ➕ Autres champs existants
  final List<String> photos; // URLs HTTPS (peut être vide)
  final double? avgRating; // moyenne sur 5 (null si aucune review)
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
    required this.ownerId,
    required this.phone,
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
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    address: json['address'] as String? ?? '',
    category: json['category'] as String? ?? '',
    latitude: (json['latitude'] ?? 0.0).toDouble(),
    longitude: (json['longitude'] ?? 0.0).toDouble(),
    ownerId: json['ownerId'] as String? ?? '', // ← fallback vide
    phone: json['phone'] as String? ?? '', // ← fallback vide
    photos: List<String>.from(json['photos'] ?? []),
    avgRating: (json['avgRating'] as num?)?.toDouble(),
    reviewsCount: json['reviewsCount'] as int?,
    geohash: json['geohash'] as String?,
    active: json['active'] as bool? ?? true,
    slots: {},
    maxReduction: json['maxReduction'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'address': address,
    'category': category,
    'latitude': latitude,
    'longitude': longitude,
    'ownerId': ownerId,
    'phone': phone,
    'photos': photos,
    'avgRating': avgRating,
    'reviewsCount': reviewsCount,
    'geohash': geohash,
    'active': active,
    'maxReduction': maxReduction,
  };

  factory Partner.fromMap(Map<String, dynamic> data, String id) {
    final rawSlots = data['slots'] as Map<String, dynamic>? ?? {};
    final parsedSlots = <String, List<Map<String, dynamic>>>{};
    for (final entry in rawSlots.entries) {
      parsedSlots[entry.key] = List<Map<String, dynamic>>.from(
        entry.value ?? [],
      );
    }

    return Partner(
      id: id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      address: data['address'] as String? ?? '',
      category: data['category'] as String? ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      ownerId: data['ownerId'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      avgRating: (data['avgRating'] as num?)?.toDouble(),
      reviewsCount: data['reviewsCount'] as int?,
      geohash: data['geohash'] as String?,
      active: data['active'] as bool? ?? true,
      slots: parsedSlots,
      maxReduction: data['maxReduction'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'address': address,
    'category': category,
    'latitude': latitude,
    'longitude': longitude,
    'ownerId': ownerId,
    'phone': phone,
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
