// -----------------------------------------------------------------------------
// Modèle Slot : créneau horaire lié à une Quest
// -----------------------------------------------------------------------------
import 'package:cloud_firestore/cloud_firestore.dart';

/// Helpers génériques ----------------------------------------------------------------
DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is String) return DateTime.parse(v);
  throw ArgumentError('Unsupported date value: $v');
}

Timestamp? _toTimestamp(DateTime? d) =>
    d == null ? null : Timestamp.fromDate(d);

/// Modèle ---------------------------------------------------------------------------
class Slot {
  final String id;
  final String questId;
  final DateTime startTime;
  final int duration;
  final bool reserved;
  final int priceCents;
  final String currency;
  final double? taxRate;
  final int discountCount;
  final Map<String, dynamic>? recurrence;
  final String? recurrenceGroupId;
  final List<DateTime> exceptions;
  final DateTime? createdAt;
  final int capacity;

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
    this.capacity = 1,
  });

  /* ---------- Factory depuis Map Firestore ---------- */
  factory Slot.fromMap(Map<String, dynamic> map) => Slot(
    id: map['id'] as String,
    questId: map['questId'] as String,
    startTime: _toDate(map['startTime'])!,
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
            ?.map((e) => _toDate(e)!)
            .toList() ??
        [],
    createdAt: _toDate(map['createdAt']),
    capacity: map['duration'] as int? ?? 1,
  );

  /* ---------- JSON <-> Model ---------- */
  factory Slot.fromJson(Map<String, dynamic> json) => Slot.fromMap(json);

  Map<String, dynamic> toJson() => {
    'id': id,
    'questId': questId,
    'startTime': _toTimestamp(startTime),
    'duration': duration,
    'reserved': reserved,
    'priceCents': priceCents,
    'currency': currency,
    'taxRate': taxRate,
    'discountCount': discountCount,
    'recurrence': recurrence,
    'recurrenceGroupId': recurrenceGroupId,
    'exceptions': exceptions
        .map((d) => _toTimestamp(d))
        .toList(growable: false),
    'createdAt': _toTimestamp(createdAt) ?? FieldValue.serverTimestamp(),
    'capacity': capacity,
  };

  /* ---------- Utilitaire copyWith ---------- */
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
    int? capacity,
  }) => Slot(
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
    capacity: capacity ?? this.capacity,
  );
  // Durée en minutes → calcule endTime
  DateTime get endTime => startTime.add(Duration(minutes: duration));

  // Nb de réservations (placeholder pour l’instant)
  int get bookedCount => 0; // TODO: connecter aux bookings

  // Réductions (placeholder vide pour le moment)
  List<String> get discounts => []; // TODO: connecter à Firestore plus tard
}
