import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 👤 Service pour gérer les données utilisateur (/users/{uid}).
class UserService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Récupère les données du profil actuel.
  static Future<DocumentSnapshot<Map<String, dynamic>>>
  getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');
    return _firestore.collection('users').doc(user.uid).get();
  }

  /// Met à jour des champs du profil actuel.
  static Future<void> updateUserData(Map<String, dynamic> updatedFields) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');
    await _firestore.collection('users').doc(user.uid).update(updatedFields);
  }

  /// Récupère la liste des IDs favoris.
  static Future<List<String>> getFavorites() async {
    final snap = await getCurrentUserData();
    return List<String>.from(snap.data()?['favorites'] ?? []);
  }
}
