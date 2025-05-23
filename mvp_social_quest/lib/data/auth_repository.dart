import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository._(this._auth);
  final FirebaseAuth _auth;
  static final instance = AuthRepository._(FirebaseAuth.instance);

  Stream<User?> authChanges() => _auth.authStateChanges();
  User? get current => _auth.currentUser;

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) => _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) => _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();
}
