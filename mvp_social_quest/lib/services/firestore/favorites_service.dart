import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/partner/partner.dart';

/// 🔖 Service de gestion des favoris de l’utilisateur.
///
/// Les favoris sont stockés en tableau de partnerId dans `/users/{uid}.favorites`.
class FavoritesService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Retourne en temps réel la liste des IDs favoris de l'utilisateur.
  static Stream<List<String>> favoriteIdsStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore.collection('users').doc(user.uid).snapshots().map((snap) {
      final data = snap.data();
      return List<String>.from(data?['favorites'] ?? []);
    });
  }

  /// Retourne en temps réel la liste des Partner complets favoris (<=10 par requête).
  static Stream<List<Partner>> favoritePartnersStream() {
    return favoriteIdsStream().asyncMap((ids) async {
      if (ids.isEmpty) return [];
      final chunks = <List<String>>[];
      for (var i = 0; i < ids.length; i += 10) {
        chunks.add(ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10));
      }
      final results = await Future.wait(
        chunks.map((chunk) async {
          final snap =
              await _firestore
                  .collection('partners')
                  .where(FieldPath.documentId, whereIn: chunk)
                  .get();
          return snap.docs
              .map((doc) => Partner.fromMap(doc.data(), doc.id))
              .toList();
        }),
      );
      return results.expand((e) => e).toList();
    });
  }

  /// Ajoute ou retire un partnerId de la liste des favoris de l'utilisateur.
  static Future<void> toggleFavorite(String partnerId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final ref = _firestore.collection('users').doc(user.uid);
    final snap = await ref.get();
    final current = List<String>.from(snap.data()?['favorites'] ?? []);

    final update =
        current.contains(partnerId)
            ? FieldValue.arrayRemove([partnerId])
            : FieldValue.arrayUnion([partnerId]);

    await ref.update({'favorites': update});
  }

  /// Sync helper : permet de savoir si un partnerId est dans la liste.
  static bool isFavoritedSync(List<String> favIds, String partnerId) {
    return favIds.contains(partnerId);
  }
}
