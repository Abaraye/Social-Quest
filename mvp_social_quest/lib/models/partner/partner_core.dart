// lib/models/partner/partner_core.dart

/// 🔑 Champs de base d’un partenaire / activité
class PartnerCore {
  final String id;
  final String name;
  final String description;
  final String address;
  final String category;
  final bool active;

  const PartnerCore({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.category,
    required this.active,
  });

  /// Validation minimale des champs essentiels
  bool get isValid =>
      name.isNotEmpty && description.isNotEmpty && category.isNotEmpty;

  /// Sérialisation partielle pour Firestore
  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'address': address,
    'category': category,
    'active': active,
  };
}
