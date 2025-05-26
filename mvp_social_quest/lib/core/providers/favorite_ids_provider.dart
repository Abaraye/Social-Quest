import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final favoriteIdsProvider = StreamProvider<List<String>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();

  final doc = FirebaseFirestore.instance.collection('users').doc(uid);
  return doc.snapshots().map((snap) {
    final data = snap.data();
    if (data == null) return <String>[];
    return List<String>.from(data['favorites'] ?? []);
  });
});
