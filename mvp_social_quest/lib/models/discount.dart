// lib/models/discount.dart
// -----------------------------------------------------------------------------
// Modèle Discount : représente une réduction associée à un créneau.

import 'package:cloud_firestore/cloud_firestore.dart';

enum DiscountType { group, lastMinute, challenge }

class Discount {
  final String id;
  final DiscountType type;
  final Map<String, dynamic> details;
  final DateTime createdAt;

  Discount({
    required this.id,
    required this.type,
    required this.details,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'details': details,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory Discount.fromJson(Map<String, dynamic> map) {
    return Discount(
      id: map['id'] ?? '',
      type: DiscountType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DiscountType.group,
      ),
      details: Map<String, dynamic>.from(map['details'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Discount copyWith({
    String? id,
    DiscountType? type,
    Map<String, dynamic>? details,
    DateTime? createdAt,
  }) {
    return Discount(
      id: id ?? this.id,
      type: type ?? this.type,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
