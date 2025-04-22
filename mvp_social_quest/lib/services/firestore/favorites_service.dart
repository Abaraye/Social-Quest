// =============================================================
// lib/services/firestore/favorites_service.dart
// =============================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/partner.dart';

/// Service unique pour la gestion des favoris (centralisé Firestore)
/// Stockage : champ `favorites` (Array<String>) dans `/users/{uid}`
class FavoritesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream temps‑réel de la liste d'IDs favoris de l'utilisateur connecté.
  static Stream<List<String>> favoriteIdsStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => List<String>.from(doc.data()?['favorites'] ?? []));
  }

  /// Même stream mais directement → objets Partner (optimisé with whereIn<=10).
  static Stream<List<Partner>> favoritePartnersStream() {
    return favoriteIdsStream().asyncMap((ids) async {
      if (ids.isEmpty) return <Partner>[];
      // Firestore "whereIn" limité à 10. Si >10, on fait plusieurs requêtes.
      final chunks = <List<String>>[];
      for (var i = 0; i < ids.length; i += 10) {
        chunks.add(ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10));
      }
      final futures = chunks.map((chunk) async {
        final snap =
            await _firestore
                .collection('partners')
                .where(FieldPath.documentId, whereIn: chunk)
                .get();
        return snap.docs.map((d) => Partner.fromMap(d.data(), d.id)).toList();
      });
      final lists = await Future.wait(futures);
      return lists.expand((e) => e).toList();
    });
  }

  /// Ajoute ou retire un partenaire des favoris.
  static Future<void> toggleFavorite(String partnerId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    final current = List<String>.from(doc.data()?['favorites'] ?? []);

    if (current.contains(partnerId)) {
      await docRef.update({
        'favorites': FieldValue.arrayRemove([partnerId]),
      });
    } else {
      await docRef.update({
        'favorites': FieldValue.arrayUnion([partnerId]),
      });
    }
  }

  /// Savoir si un ID est dans la liste locale (confort).
  static bool isFavoritedSync(List<String> favIds, String partnerId) {
    return favIds.contains(partnerId);
  }
}
