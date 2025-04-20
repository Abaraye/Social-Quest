// lib/services/firestore/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service de gestion des utilisateurs dans Firestore (collection /users)
class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Récupère l'utilisateur actuel
  static Future<DocumentSnapshot<Map<String, dynamic>>>
  getCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    return _firestore.collection('users').doc(user.uid).get();
  }

  /// 🔹 Met à jour un champ quelconque dans le profil utilisateur
  static Future<void> updateUserData(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    await _firestore.collection('users').doc(user.uid).update(data);
  }

  /// 🔹 Ajoute un partenaire aux favoris
  static Future<void> addFavorite(String partnerId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    await _firestore.collection('users').doc(user.uid).update({
      'favorites': FieldValue.arrayUnion([partnerId]),
    });
  }

  /// 🔹 Supprime un partenaire des favoris
  static Future<void> removeFavorite(String partnerId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    await _firestore.collection('users').doc(user.uid).update({
      'favorites': FieldValue.arrayRemove([partnerId]),
    });
  }

  /// 🔹 Récupère les favoris de l'utilisateur (optionnel selon les cas d'usage)
  static Future<List<String>> getFavorites() async {
    final userDoc = await getCurrentUserData();
    final data = userDoc.data();
    if (data == null) return [];

    return List<String>.from(data['favorites'] ?? []);
  }
}
