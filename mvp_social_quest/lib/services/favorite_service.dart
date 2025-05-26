import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteService {
  final FirebaseFirestore _db;

  FavoriteService(this._db);

  Future<void> toggleFavorite(String userId, String questId, bool isFav) async {
    final ref = _db.collection('users').doc(userId);
    if (isFav) {
      await ref.update({
        'favorites': FieldValue.arrayRemove([questId]),
      });
    } else {
      await ref.set({
        'favorites': FieldValue.arrayUnion([questId]),
      }, SetOptions(merge: true));
    }
  }
}
