import 'package:cloud_firestore/cloud_firestore.dart';

typedef Reduction = Map<String, dynamic>;

/// 🎫 Modèle d'une réservation utilisateur
class Booking {
  final String id;
  final String userId;
  final String partnerId;
  final String slotId;
  final Reduction reductionChosen;
  final Timestamp createdAt;
  final Timestamp startTime; // ✅ Ajout ici

  Booking({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.slotId,
    required this.reductionChosen,
    required this.createdAt,
    required this.startTime, // ✅ Ajout ici
  });

  factory Booking.fromMap(Map<String, dynamic> data, String id) {
    return Booking(
      id: id,
      userId: data['userId'] ?? '',
      partnerId: data['partnerId'] ?? '',
      slotId: data['slotId'] ?? '',
      reductionChosen: Map<String, dynamic>.from(data['reductionChosen'] ?? {}),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      startTime: data['startTime'] ?? Timestamp.now(), // ✅ Important
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'partnerId': partnerId,
    'slotId': slotId,
    'reductionChosen': reductionChosen,
    'createdAt': createdAt,
    'startTime': startTime,
  };
}
