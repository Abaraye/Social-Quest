import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/partner.dart';

/// Service centralisé pour gérer les activités (Partenaire) et leurs créneaux (slots)
class PartnerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔄 Stream temps réel de tous les partenaires
  static Stream<List<Partner>> getPartners() {
    return _firestore.collection('partners').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Partner.fromMap(data, doc.id);
      }).toList();
    });
  }

  /// ➕ Crée une nouvelle activité
  static Future<String> createPartner({
    required String name,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    int? maxReduction,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final docRef = await _firestore.collection('partners').add({
      'name': name,
      'description': description,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'ownerId': user.uid,
      'maxReduction': maxReduction ?? 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// ✏️ Met à jour une activité existante
  static Future<void> updatePartner({
    required String partnerId,
    required Map<String, dynamic> updatedData,
  }) async {
    await _firestore.collection('partners').doc(partnerId).update(updatedData);
  }

  /// ➕ Ajoute un créneau à une activité
  static Future<String> addSlot({
    required String partnerId,
    required DateTime startTime,
    required List<Map<String, dynamic>> reductions,
  }) async {
    final docRef = await _firestore
        .collection('partners')
        .doc(partnerId)
        .collection('slots')
        .add({
          'startTime': Timestamp.fromDate(startTime),
          'reductions': reductions,
          'createdAt': FieldValue.serverTimestamp(),
        });

    return docRef.id;
  }

  /// 🗑 Supprime un créneau spécifique
  static Future<void> deleteSlot({
    required String partnerId,
    required String slotId,
  }) async {
    await _firestore
        .collection('partners')
        .doc(partnerId)
        .collection('slots')
        .doc(slotId)
        .delete();
  }

  /// 🔁 Met à jour les réductions d’un créneau existant
  static Future<void> updateSlotReductions({
    required String partnerId,
    required String slotId,
    required List<Map<String, dynamic>> reductions,
  }) async {
    await _firestore
        .collection('partners')
        .doc(partnerId)
        .collection('slots')
        .doc(slotId)
        .update({'reductions': reductions});
  }

  /// 🔁 Récupère tous les créneaux d’un partenaire
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
        ...data,
        'id': doc.id,
        'startTime': data['startTime'],
        'reductions': List<Map<String, dynamic>>.from(data['reductions'] ?? []),
      };
    }).toList();
  }

  static Future<Partner> getPartnerById(String id) async {
    final doc = await _firestore.collection('partners').doc(id).get();
    if (!doc.exists) {
      throw Exception('Activité introuvable');
    }

    return Partner.fromMap(doc.data()!, doc.id);
  }
}
