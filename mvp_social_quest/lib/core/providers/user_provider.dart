import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_social_quest/core/providers/auth_provider.dart';
import 'package:mvp_social_quest/core/providers/repository_providers.dart';
import '../../models/user.dart';

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final uid = ref.watch(authProvider).value?.uid; // ✅ via authProvider
  if (uid == null) return null;
  return ref.read(userRepoProvider).fetch(uid);
});

final favoriteIdsProvider = Provider<List<String>>((ref) {
  final user = ref
      .watch(currentUserProvider)
      .maybeWhen(data: (u) => u, orElse: () => null);
  return user?.favorites ?? <String>[];
});
