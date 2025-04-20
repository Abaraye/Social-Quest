// lib/services/firestore/slot_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SlotService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          final start = data['startTime'];
          final reductions = data['reductions'];
          if (start == null || reductions == null) return null;
          return {
            'id': doc.id,
            'startTime': start,
            'reductions': List<Map<String, dynamic>>.from(reductions),
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static Future<void> addSlot(
    String partnerId,
    Map<String, dynamic> slotData,
  ) async {
    await _firestore
        .collection('partners')
        .doc(partnerId)
        .collection('slots')
        .add(slotData);
  }

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

  static Future<void> deleteSlot(String partnerId, String slotId) async {
    await _firestore
        .collection('partners')
        .doc(partnerId)
        .collection('slots')
        .doc(slotId)
        .delete();
  }
}
