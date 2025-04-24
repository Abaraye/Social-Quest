// lib/models/partner/partner_location.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// 🌍 Localisation et géohash pour recherche géographique
class PartnerLocation {
  final double latitude;
  final double longitude;
  final String? geohash;

  const PartnerLocation({
    required this.latitude,
    required this.longitude,
    this.geohash,
  });

  factory PartnerLocation.fromMap(Map<String, dynamic> data) {
    return PartnerLocation(
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      geohash: data['geohash'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
    'geohash': geohash,
  };
}
