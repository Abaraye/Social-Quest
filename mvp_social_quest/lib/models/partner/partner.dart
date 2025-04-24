import 'package:cloud_firestore/cloud_firestore.dart';

/// Représente un commerçant / partenaire.
class Partner {
  /// L’identifiant Firestore du document.
  final String id;

  /// Nom de l’activité.
  final String name;

  /// Description de l’activité.
  final String description;

  /// Catégorie (ex: Cuisine, Sport…).
  final String category;

  /// Adresse complète (optionnelle).
  final String? address;

  /// URL des photos (peut être vide).
  final List<String> photos;

  /// Note moyenne (0–5) ou null si pas encore noté.
  final double? avgRating;

  /// Pourcentage de réduction max proposé.
  final int maxReductionDisplay;

  /// Crée une instance à partir d’un snapshot Firestore.
  factory Partner.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Partner(
      id: snap.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      address: data['address'] as String?,
      photos: List<String>.from(data['photos'] ?? []),
      avgRating: (data['avgRating'] as num?)?.toDouble(),
      maxReductionDisplay: (data['maxReductionDisplay'] as num?)?.toInt() ?? 0,
    );
  }

  /// Crée une instance à partir d’une map Firestore et d’un ID.
  factory Partner.fromMap(Map<String, dynamic> data, String id) {
    return Partner(
      id: id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      address: data['address'] as String?,
      photos: List<String>.from(data['photos'] ?? []),
      avgRating: (data['avgRating'] as num?)?.toDouble(),
      maxReductionDisplay: (data['maxReductionDisplay'] as num?)?.toInt() ?? 0,
    );
  }

  Partner({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.address,
    this.photos = const [],
    this.avgRating,
    this.maxReductionDisplay = 0,
  });

  /// Exporte en map Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      if (address != null) 'address': address,
      'photos': photos,
      if (avgRating != null) 'avgRating': avgRating,
      'maxReductionDisplay': maxReductionDisplay,
    };
  }

  /// Copie l’objet en modifiant certains champs.
  Partner copyWith({
    String? name,
    String? description,
    String? category,
    String? address,
    List<String>? photos,
    double? avgRating,
    int? maxReductionDisplay,
  }) {
    return Partner(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      address: address ?? this.address,
      photos: photos ?? this.photos,
      avgRating: avgRating ?? this.avgRating,
      maxReductionDisplay: maxReductionDisplay ?? this.maxReductionDisplay,
    );
  }
}
