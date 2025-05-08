import 'package:cloud_firestore/cloud_firestore.dart';

/// 📦 Modèle Booking : représente une réservation d'activité
class Booking {
  final String id;
  final String userId;
  final String partnerId;
  final String questId;
  final String slotId;
  final int peopleCount;
  final int totalPriceCents;
  final String currency;
  final String status; // 'confirmed', 'canceled', etc.
  final DateTime startTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.questId,
    required this.slotId,
    required this.peopleCount,
    required this.totalPriceCents,
    required this.currency,
    required this.status,
    required this.startTime,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 🔄 Factory pour recréer un Booking à partir d'un document Firestore
  factory Booking.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      partnerId: data['partnerId'] ?? '',
      questId: data['questId'] ?? '',
      slotId: data['slotId'] ?? '',
      peopleCount: data['peopleCount'] ?? 1,
      totalPriceCents: data['totalPriceCents'] ?? 0,
      currency: data['currency'] ?? 'EUR',
      status: data['status'] ?? 'confirmed',
      startTime: (data['startTime'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// 🔄 Transforme un Booking en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'partnerId': partnerId,
      'questId': questId,
      'slotId': slotId,
      'peopleCount': peopleCount,
      'totalPriceCents': totalPriceCents,
      'currency': currency,
      'status': status,
      'startTime': Timestamp.fromDate(startTime),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
