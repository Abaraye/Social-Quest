// lib/data/discount_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/discount.dart';

/// Repository Firestore pour les réductions, stockées
/// en tant que sous-collection de chaque slot.
class DiscountRepository {
  DiscountRepository._(this._firestore);
  static final instance = DiscountRepository._(FirebaseFirestore.instance);
  final FirebaseFirestore _firestore;

  /// Référence à la sous-collection 'discounts' du slot
  CollectionReference<Map<String, dynamic>> _discountsRef({
    required String slotId,
  }) {
    return _firestore.collection('slots').doc(slotId).collection('discounts');
  }

  /// Ecoute en temps réel la liste des réductions pour un slot
  Stream<List<Discount>> watchAll({required String slotId}) {
    return _discountsRef(slotId: slotId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) {
                final data = doc.data();
                return Discount(
                  id: doc.id,
                  type: DiscountType.values.firstWhere(
                    (e) => e.name == data['type'],
                    orElse: () => DiscountType.group,
                  ),
                  details: Map<String, dynamic>.from(data['details']),
                  createdAt: (data['createdAt'] as Timestamp).toDate(),
                );
              }).toList(),
        );
  }

  /// Récupère une réduction spécifique
  Future<Discount?> fetch({
    required String slotId,
    required String discountId,
  }) async {
    final doc = await _discountsRef(slotId: slotId).doc(discountId).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return Discount(
      id: doc.id,
      type: DiscountType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => DiscountType.group,
      ),
      details: Map<String, dynamic>.from(data['details']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Crée ou met à jour une réduction
  Future<void> save({
    required String slotId,
    required Discount discount,
  }) async {
    final col = _discountsRef(slotId: slotId);
    final data = {
      'type': discount.type.name,
      'details': discount.details,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (discount.id.isEmpty) {
      await col.add(data);
    } else {
      await col.doc(discount.id).set(data, SetOptions(merge: true));
    }
  }

  /// Supprime une réduction
  Future<void> delete({
    required String slotId,
    required String discountId,
  }) async {
    await _discountsRef(slotId: slotId).doc(discountId).delete();
  }
}
