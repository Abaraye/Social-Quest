// =============================================================
// lib/services/firestore/slot_service.dart – v3.1
// =============================================================
// 🔄 Gère les slots avec support des créneaux récurrents
// ✅ Nouvelle méthode : getExpandedPartnerSlots()
// -------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class SlotService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔍 Récupère tous les créneaux (simples ou récurrents)
  static Future<List<Map<String, dynamic>>> getPartnerSlots(
    String partnerId,
  ) async {
    final snapshot =
        await _firestore
            .collection('partners')
            .doc(partnerId)
            .collection('slots')
            .orderBy('startTime')
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'startTime': data['startTime'],
        'reductions': List<Map<String, dynamic>>.from(data['reductions'] ?? []),
        'recurrence': data['recurrence'],
        'recurrenceGroupId': data['recurrenceGroupId'],
      };
    }).toList();
  }

  /// 🔍 Récupère et étend les créneaux récurrents (pour affichage utilisateur)
  static Future<List<Map<String, dynamic>>> getExpandedPartnerSlots(
    String partnerId,
  ) async {
    final slots = await getPartnerSlots(partnerId);
    final now = DateTime.now();

    final expanded = <Map<String, dynamic>>[];

    for (final slot in slots) {
      final start = (slot['startTime'] as Timestamp).toDate();
      final recurrence = slot['recurrence'] as Map<String, dynamic>?;

      if (recurrence == null || recurrence['type'] == 'Aucune') {
        if (start.isAfter(now)) expanded.add(slot);
        continue;
      }

      final type = recurrence['type'];
      final endDate = (recurrence['endDate'] as Timestamp?)?.toDate() ?? start;
      DateTime current = start;

      while (!current.isAfter(endDate)) {
        if (current.isAfter(now)) {
          expanded.add({
            'id': slot['id'],
            'startTime': Timestamp.fromDate(current),
            'reductions': slot['reductions'],
            'recurrenceGroupId': slot['recurrenceGroupId'],
            'originalStartTime': slot['startTime'],
          });
        }

        switch (type) {
          case 'Tous les jours':
            current = current.add(const Duration(days: 1));
            break;
          case 'Chaque semaine':
          case 'Tous les lundis':
            current = current.add(const Duration(days: 7));
            break;
          default:
            break;
        }
      }
    }

    // Tri par date
    expanded.sort((a, b) {
      final at = (a['startTime'] as Timestamp).toDate();
      final bt = (b['startTime'] as Timestamp).toDate();
      return at.compareTo(bt);
    });

    return expanded;
  }

  /// ➕ Ajoute un ou plusieurs créneaux selon récurrence
  static Future<void> addSlot(
    String partnerId,
    Map<String, dynamic> slotData,
  ) async {
    final recurrence = slotData['recurrence'] as Map<String, dynamic>?;
    final reductions = List<Map<String, dynamic>>.from(slotData['reductions']);
    final startTime = (slotData['startTime'] as Timestamp).toDate();
    final duration = slotData['duration'] as int;
    final recurrenceGroupId = const Uuid().v4();

    if (recurrence == null || recurrence['type'] == 'Aucune') {
      await _firestore
          .collection('partners')
          .doc(partnerId)
          .collection('slots')
          .add(slotData);
      return;
    }

    final type = recurrence['type'];
    final endDate =
        (recurrence['endDate'] as Timestamp?)?.toDate() ?? startTime;
    DateTime current = startTime;

    while (!current.isAfter(endDate)) {
      await _firestore
          .collection('partners')
          .doc(partnerId)
          .collection('slots')
          .add({
            'startTime': Timestamp.fromDate(current),
            'duration': duration,
            'reductions': reductions,
            'recurrence': recurrence,
            'recurrenceGroupId': recurrenceGroupId,
            'createdAt': FieldValue.serverTimestamp(),
            'isRecurring': true,
          });

      switch (type) {
        case 'Tous les jours':
          current = current.add(const Duration(days: 1));
          break;
        case 'Chaque semaine':
        case 'Tous les lundis':
          current = current.add(const Duration(days: 7));
          break;
        default:
          return;
      }
    }
  }

  /// ✏️ Mise à jour des réductions d’un créneau
  static Future<void> updateSlotReductions(
    String partnerId,
    String slotId,
    List<Map<String, dynamic>> reductions,
  ) async {
    await _firestore
        .collection('partners')
        .doc(partnerId)
        .collection('slots')
        .doc(slotId)
        .update({'reductions': reductions});
  }

  /// 🔁 Mise à jour groupée des créneaux d’une récurrence
  static Future<void> updateRecurrenceGroup(
    String partnerId,
    String recurrenceGroupId,
    Map<String, dynamic> updates,
  ) async {
    final group =
        await _firestore
            .collection('partners')
            .doc(partnerId)
            .collection('slots')
            .where('recurrenceGroupId', isEqualTo: recurrenceGroupId)
            .get();

    for (final doc in group.docs) {
      await doc.reference.update(updates);
    }
  }

  /// 🗑️ Supprime un seul créneau
  static Future<void> deleteSlot(String partnerId, String slotId) async {
    await _firestore
        .collection('partners')
        .doc(partnerId)
        .collection('slots')
        .doc(slotId)
        .delete();
  }

  /// 🗑️ Supprime toute une récurrence via recurrenceGroupId
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
