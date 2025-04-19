// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/partner.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Crée une réservation dans la collection `/bookings`
  static Future<void> createBooking({
    required String partnerId,
    required String selectedSlot,
    required String selectedDiscount,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    await _firestore.collection('bookings').add({
      'userId': user.uid,
      'partnerId': partnerId,
      'selectedSlot': selectedSlot,
      'selectedDiscount': selectedDiscount,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 🔹 Récupère les partenaires depuis Firestore
  static Stream<List<Partner>> getPartners() {
    return _firestore.collection('partners').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Partner.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// 🔹 Ajoute un partenaire dans la collection `/partners`
  static Future<void> createPartner({
    required String name,
    required String description,
    required String category,
    required Map<String, List<String>> slots,
    required double latitude,
    required double longitude,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    await FirebaseFirestore.instance.collection('partners').add({
      'name': name,
      'description': description,
      'category': category,
      'slots': slots,
      'latitude': latitude,
      'longitude': longitude,
      'ownerId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
