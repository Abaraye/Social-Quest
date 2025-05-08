// lib/models/slot.dart
// -----------------------------------------------------------------------------
// Modèle de créneau horaire (Slot), lié à une Quest.
// Mise à jour : Suppression de la liste de réductions directe.
// Les réductions sont désormais une sous-collection Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';

class Slot {
  /// Identifiant Firestore du document.
  final String id;

  /// Identifiant de la Quest associée.
  final String questId;

  /// Date et heure de début du créneau.
  final DateTime startTime;

  /// Durée du créneau en minutes.
  final int duration;

  /// Statut de réservation (false par défaut).
  final bool reserved;

  /// Prix TTC en centimes d'euro.
  final int priceCents;

  /// Devise ISO-4217 ("EUR" par défaut).
  final String currency;

  /// Taux de TVA applicable (optionnel).
  final double? taxRate;

  /// Nombre de réductions associées (champ pratique pour UI).
  final int discountCount;

  /// Paramètres de récurrence (facultatif).
  final Map<String, dynamic>? recurrence;

  /// Identifiant de groupe de récurrence.
  final String? recurrenceGroupId;

  /// Dates d'exceptions (exclusions de récurrence).
  final List<DateTime> exceptions;

  /// Timestamp de création.
  final DateTime? createdAt;

  const Slot({
    required this.id,
    required this.questId,
    required this.startTime,
    required this.duration,
    this.reserved = false,
    this.priceCents = 0,
    this.currency = 'EUR',
    this.taxRate,
    this.discountCount = 0,
    this.recurrence,
    this.recurrenceGroupId,
    this.exceptions = const [],
    this.createdAt,
  });

  /// Crée une instance Slot depuis une map Firestore.
  factory Slot.fromMap(Map<String, dynamic> map) {
    return Slot(
      id: map['id'] as String,
      questId: map['questId'] as String,
      startTime: (map['startTime'] as Timestamp).toDate(),
      duration: map['duration'] as int? ?? 60,
      reserved: map['reserved'] as bool? ?? false,
      priceCents: map['priceCents'] as int? ?? 0,
      currency: map['currency'] as String? ?? 'EUR',
      taxRate: (map['taxRate'] as num?)?.toDouble(),
      discountCount: map['discountCount'] as int? ?? 0,
      recurrence:
          map['recurrence'] != null
              ? Map<String, dynamic>.from(map['recurrence'])
              : null,
      recurrenceGroupId: map['recurrenceGroupId'] as String?,
      exceptions:
          (map['exceptions'] as List<dynamic>?)
              ?.map((e) => (e as Timestamp).toDate())
              .toList() ??
          [],
      createdAt:
          map['createdAt'] != null
              ? (map['createdAt'] as Timestamp).toDate()
              : null,
    );
  }

  /// Convertit une instance Slot en map pour Firestore.
  Map<String, dynamic> toMap() {
    return {
      'questId': questId,
      'startTime': Timestamp.fromDate(startTime),
      'duration': duration,
      'reserved': reserved,
      'priceCents': priceCents,
      'currency': currency,
      'taxRate': taxRate,
      'discountCount': discountCount,
      'recurrence': recurrence,
      'recurrenceGroupId': recurrenceGroupId,
      'exceptions': exceptions.map((d) => Timestamp.fromDate(d)).toList(),
      'createdAt':
          createdAt != null
              ? Timestamp.fromDate(createdAt!)
              : FieldValue.serverTimestamp(),
    };
  }

  /// Copie une instance Slot avec des modifications partielles.
  Slot copyWith({
    String? id,
    String? questId,
    DateTime? startTime,
    int? duration,
    bool? reserved,
    int? priceCents,
    String? currency,
    double? taxRate,
    int? discountCount,
    Map<String, dynamic>? recurrence,
    String? recurrenceGroupId,
    List<DateTime>? exceptions,
    DateTime? createdAt,
  }) {
    return Slot(
      id: id ?? this.id,
      questId: questId ?? this.questId,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      reserved: reserved ?? this.reserved,
      priceCents: priceCents ?? this.priceCents,
      currency: currency ?? this.currency,
      taxRate: taxRate ?? this.taxRate,
      discountCount: discountCount ?? this.discountCount,
      recurrence: recurrence ?? this.recurrence,
      recurrenceGroupId: recurrenceGroupId ?? this.recurrenceGroupId,
      exceptions: exceptions ?? this.exceptions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
