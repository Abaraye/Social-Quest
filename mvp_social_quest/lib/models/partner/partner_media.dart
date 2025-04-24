// lib/models/partner/partner_media.dart

/// 📸 Galerie de photos (URLs HTTPS)
class PartnerMedia {
  final List<String> photos;

  const PartnerMedia({this.photos = const []});

  factory PartnerMedia.fromMap(Map<String, dynamic> data) {
    return PartnerMedia(photos: List<String>.from(data['photos'] ?? []));
  }

  Map<String, dynamic> toMap() => {'photos': photos};
}
