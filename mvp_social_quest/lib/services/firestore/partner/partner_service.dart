// lib/services/firestore/partner_service.dart
// -----------------------------------------------------------------------------
// Service centralisé pour gérer les partenaires (collection `/partners`),
// incluant écoute, création, mise à jour et soft-delete.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/partner/partner.dart';

/// 🏷 PartnerService
/// ----------------
/// Fournit les opérations Firestore pour la collection `partners` :
/// • Flux en temps réel des partenaires liés à l'utilisateur courant
/// • Lecture, création, mise à jour et désactivation (soft-delete)
class PartnerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔄 Flux temps réel des partenaires actifs appartenant
  ///     à l'utilisateur connecté (ownerId == user.uid).
  static Stream<List<Partner>> streamPartners() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Aucun utilisateur → flux vide
      return const Stream.empty();
    }
    return _firestore
        .collection('partners')
        .where('active', isEqualTo: true)
        .where('ownerId', isEqualTo: user.uid)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((doc) => Partner.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  /// 📥 Récupère une fois un partenaire par son ID. Erreur si introuvable.
  static Future<Partner> getPartnerById(String partnerId) async {
    final doc = await _firestore.collection('partners').doc(partnerId).get();
    if (!doc.exists) {
      throw Exception('Partenaire introuvable (ID: \$partnerId)');
    }
    return Partner.fromMap(doc.data()!, doc.id);
  }

  /// ➕ Crée un nouveau partenaire pour l'utilisateur connecté.
  /// Retourne l'ID Firestore du document créé.
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

  /// ✏️ Met à jour partiellement un partenaire existant.
  ///     `updates` contient uniquement les champs à modifier.
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

  /// 👤 Crée ou met à jour le document `/users/{userId}`
  ///     pour définir le profil marchand avec `type: 'merchant'`.
  static Future<void> createUserProfile({
    required String userId,
    required String email,
    required String name,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'email': email,
      'name': name,
      'type': 'merchant', // Champ aligné sur userTypeProvider
      'favorites': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
