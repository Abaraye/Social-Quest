import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvp_social_quest/models/reduction.dart';

/// Représente une réservation d’un créneau.
class Booking {
  /// Identifiant Firestore du document.
  final String id;

  /// Identifiant du partenaire réservé.
  final String partnerId;

  /// Identifiant du slot template ou instance.
  final String slotId;

  /// Date/heure de l’occurrence réservée.
  final DateTime occurrence;

  /// Réduction choisie pour cette réservation.
  final Reduction reductionChosen;

  Booking({
    required this.id,
    required this.partnerId,
    required this.slotId,
    required this.occurrence,
    required this.reductionChosen,
  });

  /// Crée à partir d’un snapshot Firestore.
  factory Booking.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Booking.fromMap(data, snap.id);
  }

  /// Crée à partir d’une map et d’un ID.
  factory Booking.fromMap(Map<String, dynamic> data, String id) {
    final redMap = data['reductionChosen'] as Map<String, dynamic>;
    return Booking(
      id: id,
      partnerId: data['partnerId'] as String,
      slotId: data['slotId'] as String,
      occurrence: (data['startTime'] as Timestamp).toDate(),
      reductionChosen: Reduction.fromMap(redMap),
    );
  }

  /// Exporte en map Firestore.
  Map<String, dynamic> toMap() {
    return {
      'partnerId': partnerId,
      'slotId': slotId,
      'reductionChosen': reductionChosen.toMap(),
      'startTime': Timestamp.fromDate(occurrence),
    };
  }
}
