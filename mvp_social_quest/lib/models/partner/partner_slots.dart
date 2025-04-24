// lib/models/partner/partner_slots.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// 💼 Cache simplifié des slots (sous-collection).
/// Clé = slotId, valeur = liste de maps représentant les réductions.
class PartnerSlots {
  /// slots stockés côté Partner (optionnel / legacy).
  final Map<String, List<Map<String, dynamic>>> slots;

  /// Champ legacy pour réduction max (optionnel).
  final int? maxReduction;

  const PartnerSlots({this.slots = const {}, this.maxReduction});

  factory PartnerSlots.fromMap(Map<String, dynamic> data) {
    final raw = data['slots'] as Map<String, dynamic>? ?? {};
    final parsed = <String, List<Map<String, dynamic>>>{};
    raw.forEach((key, value) {
      parsed[key] = List<Map<String, dynamic>>.from(value ?? []);
    });
    return PartnerSlots(
      slots: parsed,
      maxReduction: data['maxReduction'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
    'slots': slots,
    'maxReduction': maxReduction,
  };

  /// Calcule à la volée la réduction maximale parmi tous les slots.
  int get computedMaxReduction {
    var best = 0;
    for (final list in slots.values) {
      for (final red in list) {
        final amt = red['amount'] as int? ?? 0;
        if (amt > best) best = amt;
      }
    }
    return best;
  }

  /// Valeur à afficher (legacy ou calculée).
  int get maxReductionDisplay => maxReduction ?? computedMaxReduction;

  /// Indique s’il reste au moins un créneau futur.
  bool get hasUpcomingSlot {
    final now = DateTime.now();
    return slots.values
        .expand((e) => e)
        .any((m) => (m['startTime'] as Timestamp).toDate().isAfter(now));
  }
}
