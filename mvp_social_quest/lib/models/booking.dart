// lib/models/booking.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🎓 Modèle de données pour une réservation utilisateur
typedef Reduction = Map<String, dynamic>;

class Booking {
  final String id;
  final String userId;
  final String partnerId;
  final String slotId;
  final Reduction reductionChosen;
  final Timestamp createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.slotId,
    required this.reductionChosen,
    required this.createdAt,
  });

  factory Booking.fromMap(Map<String, dynamic> data, String id) {
    return Booking(
      id: id,
      userId: data['userId'] ?? '',
      partnerId: data['partnerId'] ?? '',
      slotId: data['slotId'] ?? '',
      reductionChosen: Map<String, dynamic>.from(data['reductionChosen'] ?? {}),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'partnerId': partnerId,
    'slotId': slotId,
    'reductionChosen': reductionChosen,
    'createdAt': createdAt,
  };
}
