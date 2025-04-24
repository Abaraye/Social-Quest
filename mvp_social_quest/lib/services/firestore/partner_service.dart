// lib/services/firestore/partner_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/partner/partner.dart';

/// 🏷 Service centralisé pour la gestion des partenaires
/// (collection `/partners`), incluant création, lecture, mise à jour et soft-delete.
class PartnerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔄 Écoute en temps réel de tous les partenaires actifs.
  static Stream<List<Partner>> streamPartners() {
    return _firestore
        .collection('partners')
        .where('active', isEqualTo: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((doc) => Partner.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  /// 📥 Récupère une fois un partenaire par son ID.
  /// Lève une exception si introuvable.
  static Future<Partner> getPartnerById(String partnerId) async {
    final doc = await _firestore.collection('partners').doc(partnerId).get();
    if (!doc.exists) {
      throw Exception('Partenaire introuvable (ID: $partnerId)');
    }
    return Partner.fromMap(doc.data()!, doc.id);
  }

  /// ➕ Crée un nouveau partenaire.
  /// Retourne l'ID du document créé.
  static Future<String> createPartner({
    required String name,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    List<String>? photos,
    double? avgRating,
    int? reviewsCount,
    String? geohash,
    int? maxReduction,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    final data = <String, dynamic>{
      'name': name,
      'description': description,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'photos': photos ?? [],
      'avgRating': avgRating,
      'reviewsCount': reviewsCount,
      'geohash': geohash,
      'maxReduction': maxReduction ?? 0,
      'ownerId': user.uid,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final ref = await _firestore.collection('partners').add(data);
    return ref.id;
  }

  /// ✏️ Met à jour partiellement les propriétés d’un partenaire.
  /// N’inclut pas la modification de ses sous-collections (slots, reviews…).
  static Future<void> updatePartner({
    required String partnerId,
    required Map<String, dynamic> updates,
  }) async {
    await _firestore.collection('partners').doc(partnerId).update(updates);
  }

  /// 🛑 Désactive (soft-delete) un partenaire en le marquant `active: false`.
  static Future<void> deactivatePartner(String partnerId) async {
    await _firestore.collection('partners').doc(partnerId).update({
      'active': false,
    });
  }

  /// 🧑‍💼 Crée un document profil pour l'utilisateur marchand.
  static Future<void> createUserProfile({
    required String userId,
    required String email,
    required String name,
  }) async {
    // You can choose collection name as you wish; here “users”
    await _firestore.collection('users').doc(userId).set({
      'email': email,
      'name': name,
      'role': 'merchant',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
