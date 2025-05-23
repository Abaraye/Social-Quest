// lib/core/utils/firestore_helpers.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Retourne le premier partnerId d’un marchand ou null si aucun.
Future<String?> firstPartnerId(String uid) async {
  final snap =
      await FirebaseFirestore.instance
          .collection('partners')
          .where('ownerId', isEqualTo: uid)
          .limit(1)
          .get();
  return snap.docs.isEmpty ? null : snap.docs.first.id;
}
