import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvp_social_quest/core/utils/date_mapper.dart';

class Booking {
  final String id;
  final String userId;
  final String partnerId;
  final String questId;
  final String slotId;
  final int peopleCount;
  final int totalPriceCents;
  final String currency;
  final String status;
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

  /* ---------- Firestore doc ---------- */
  factory Booking.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Booking.fromJson({'id': doc.id, ...?doc.data()});

  /* ---------- JSON “pur” ---------- */
  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] as String,
    userId: json['userId'] as String,
    partnerId: json['partnerId'] as String,
    questId: json['questId'] as String,
    slotId: json['slotId'] as String,
    peopleCount: json['peopleCount'] as int,
    totalPriceCents: json['totalPriceCents'] as int,
    currency: json['currency'] as String,
    status: json['status'] as String,
    startTime: toDate(json['startTime'])!,
    createdAt: toDate(json['createdAt'])!,
    updatedAt: toDate(json['updatedAt'])!,
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'partnerId': partnerId,
    'questId': questId,
    'slotId': slotId,
    'peopleCount': peopleCount,
    'totalPriceCents': totalPriceCents,
    'currency': currency,
    'status': status,
    'startTime': toTimestamp(startTime),
    'createdAt': toTimestamp(createdAt),
    'updatedAt': toTimestamp(updatedAt),
  };
}
