import 'package:cloud_firestore/cloud_firestore.dart';

import 'reduction.dart';

/// 🎫 Modèle de créneau horaire (template ou instance).
class Slot {
  /// Identifiant Firestore du document.
  final String id;

  /// Date et heure de début.
  final DateTime startTime;

  /// Durée en minutes.
  final int duration;

  /// Indique si ce créneau est déjà réservé.
  final bool reserved;

  /// Prix TTC du créneau, exprimé en centimes (ex. 1999 = 19,99 €).
  final int priceCents;

  /// Devise ISO-4217 (par défaut « EUR »).
  final String currency;

  /// Taux de TVA appliqué (ex. 0.20 pour 20 %), nullable tant qu’on n’expose pas la TVA.
  final double? taxRate;

  /// Liste des réductions applicables.
  final List<Reduction> reductions;

  /// Paramètres de récurrence (ex : type, endDate).
  final Map<String, dynamic>? recurrence;

  /// Groupe de récurrence pour lier plusieurs templates.
  final String? recurrenceGroupId;

  /// Exceptions (dates exclues) pour un template récurrent.
  final List<DateTime> exceptions;

  /// Timestamp de création (serveur).
  final DateTime? createdAt;

  const Slot({
    required this.id,
    required this.startTime,
    required this.duration,
    this.reserved = false,
    this.priceCents = 0,
    this.currency = 'EUR',
    this.taxRate,
    this.reductions = const [],
    this.recurrence,
    this.recurrenceGroupId,
    this.exceptions = const [],
    this.createdAt,
  });

  /// Crée une instance depuis une map Firestore.
  factory Slot.fromMap(Map<String, dynamic> map) {
    return Slot(
      id: map['id'] as String,
      startTime: (map['startTime'] as Timestamp).toDate(),
      duration: map['duration'] as int? ?? 60,
      reserved: map['reserved'] as bool? ?? false,
      priceCents:
          map['priceCents'] as int? ??
          0, // 🔄 fallback : 0 pour les anciens documents
      currency: map['currency'] as String? ?? 'EUR',
      taxRate: (map['taxRate'] as num?)?.toDouble(),
      reductions:
          (map['reductions'] as List<dynamic>?)
              ?.map((e) => Reduction.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      recurrence:
          map['recurrence'] != null
              ? Map<String, dynamic>.from(map['recurrence'] as Map)
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

  /// Convertit en map pour Firestore (omet l'id).
  Map<String, dynamic> toMap() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'duration': duration,
      'reserved': reserved,
      'priceCents': priceCents,
      'currency': currency,
      'taxRate': taxRate,
      'reductions': reductions.map((r) => r.toMap()).toList(),
      'recurrence': recurrence,
      'recurrenceGroupId': recurrenceGroupId,
      'exceptions': exceptions.map((d) => Timestamp.fromDate(d)).toList(),
      'createdAt':
          createdAt != null
              ? Timestamp.fromDate(createdAt!)
              : FieldValue.serverTimestamp(),
    };
  }

  /// Copie le slot en remplaçant certains champs.
  Slot copyWith({
    String? id,
    DateTime? startTime,
    int? duration,
    bool? reserved,
    int? priceCents,
    String? currency,
    double? taxRate,
    List<Reduction>? reductions,
    Map<String, dynamic>? recurrence,
    String? recurrenceGroupId,
    List<DateTime>? exceptions,
    DateTime? createdAt,
  }) {
    return Slot(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      reserved: reserved ?? this.reserved,
      priceCents: priceCents ?? this.priceCents,
      currency: currency ?? this.currency,
      taxRate: taxRate ?? this.taxRate,
      reductions: reductions ?? this.reductions,
      recurrence: recurrence ?? this.recurrence,
      recurrenceGroupId: recurrenceGroupId ?? this.recurrenceGroupId,
      exceptions: exceptions ?? this.exceptions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Slot(id: $id, startTime: $startTime, duration: $duration, '
        'reserved: $reserved, priceCents: $priceCents $currency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Slot &&
        other.id == id &&
        other.startTime == startTime &&
        other.duration == duration &&
        other.reserved == reserved &&
        other.priceCents == priceCents &&
        other.currency == currency &&
        other.taxRate == taxRate;
  }

  @override
  int get hashCode =>
      Object.hash(id, startTime, duration, reserved, priceCents, currency);
}
