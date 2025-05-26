import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/auth_repository.dart';

/// État d’authentification courant (User?).
final authProvider = StreamProvider<User?>((ref) {
  final stream = FirebaseAuth.instance.authStateChanges();
  stream.listen((user) => print('[authProvider] user = $user'));
  return stream;
});
