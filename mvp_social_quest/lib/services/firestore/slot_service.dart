import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../models/slot.dart';
import 'recurrence_helper.dart';

/// ⏰ Service de gestion des créneaux (collection `/partners/{pid}/slots`).
class SlotService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Uuid _uuid = Uuid();

  // ───────────────────────────────────────────────────────── Stream raw/expanded
  /// 📥 Flux temps réel des slots bruts (templates + one-off).
  static Stream<List<Slot>> streamRawSlots(String partnerId) {
    return _firestore
        .collection('partners')
        .doc(partnerId)
        .collection('slots')
        .orderBy('startTime')
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((d) => Slot.fromMap({...d.data(), 'id': d.id}))
                  .toList(),
        );
  }

  /// 🔄 Flux temps réel des occurrences étendues (réccurence + exceptions).
  static Stream<List<Slot>> streamExpandedSlots(String partnerId) {
    return streamRawSlots(partnerId).map((rawSlots) {
      final now = DateTime.now();
      final expanded = <Slot>[];
      for (final slot in rawSlots) {
        expanded.addAll(RecurrenceHelper.expand(slot, now: now));
      }
      expanded.sort((a, b) => a.startTime.compareTo(b.startTime));
      return expanded;
    });
  }

  /// 📖 Lecture unique de la liste étendue des créneaux.
  static Future<List<Slot>> getExpandedSlots(String partnerId) async =>
      streamExpandedSlots(partnerId).first;

  /// 🛑 Alias historique (conservé pour ne pas casser les appels existants).
  @Deprecated('Renommé en getExpandedSlots() – À migrer puis supprimer.')
  static Future<List<Slot>> getExpandedPartnerSlots(String partnerId) =>
      getExpandedSlots(partnerId);

  // ─────────────────────────────────────────────────────────── CRUD principal
  /// ➕ Ajoute un template de créneau (récurrent ou non).
  static Future<void> addSlot(String partnerId, Slot slot) async {
    final col = _firestore
        .collection('partners')
        .doc(partnerId)
        .collection('slots');
    final data =
        slot.toMap()
          ..remove('id')
          ..addAll({
            'createdAt': FieldValue.serverTimestamp(),
            if (slot.recurrence != null) 'recurrenceGroupId': _uuid.v4(),
          });
    await col.add(data);
  }

  /// ➕ Ajoute un slot one-off (instance), avec option `reserved`.
  static Future<void> addInstanceSlot(
    String partnerId,
    Slot slot, {
    bool reserved = false,
  }) async {
    final col = _firestore
        .collection('partners')
        .doc(partnerId)
        .collection('slots');
    final data = {
      ...slot.toMap()..remove('id'),
      'reserved': reserved,
      'recurrence': null,
      'recurrenceGroupId': null,
      'exceptions': <Timestamp>[],
      'createdAt': FieldValue.serverTimestamp(),
    };
    await col.add(data);
  }

  /// 🔒 Bloque une occurrence d’un slot récurrent.
  static Future<void> blockOccurrence(
    String partnerId,
    Slot template,
    DateTime occurrence,
  ) async {
    await deleteSingleOccurrence(partnerId, template.id, occurrence);
    await addInstanceSlot(
      partnerId,
      template.copyWith(startTime: occurrence),
      reserved: true,
    );
  }

  /// ✔️ Marque un slot unique comme réservé.
  static Future<void> markReserved(String partnerId, String slotId) async {
    await _firestore
        .collection('partners')
        .doc(partnerId)
        .collection('slots')
        .doc(slotId)
        .update({'reserved': true});
  }

  /// ✏️ Met à jour un template ou une instance de slot.
  static Future<void> updateSlot({
    required String partnerId,
    required String slotId,
    required Map<String, dynamic> updates,
  }) {
    return _firestore
        .collection('partners')
        .doc(partnerId)
        .collection('slots')
        .doc(slotId)
        .update(updates);
  }

  /// 🚫 Ajoute une date à `exceptions` pour un template récurrent.
  static Future<void> deleteSingleOccurrence(
    String partnerId,
    String slotId,
    DateTime occurrence,
  ) {
    return _firestore
        .collection('partners')
        .doc(partnerId)
        .collection('slots')
        .doc(slotId)
        .update({
          'exceptions': FieldValue.arrayUnion([Timestamp.fromDate(occurrence)]),
        });
  }

  /// 🗑️ Supprime toute une récurrence via `recurrenceGroupId`.
  static Future<void> deleteRecurrenceGroup(
    String partnerId,
    String recurrenceGroupId,
  ) async {
    final group =
        await _firestore
            .collection('partners')
            .doc(partnerId)
            .collection('slots')
            .where('recurrenceGroupId', isEqualTo: recurrenceGroupId)
            .get();

    for (final doc in group.docs) {
      await doc.reference.delete();
    }
  }
}
