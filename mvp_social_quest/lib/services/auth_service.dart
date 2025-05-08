import 'package:firebase_auth/firebase_auth.dart';

/// Service d’auth ultra‐léger + helpers statiques “one-liner”.
class AuthService {
  AuthService._(this._auth);

  final FirebaseAuth _auth;
  static final AuthService _instance = AuthService._(FirebaseAuth.instance);
  static AuthService get instance => _instance;

  /* ---------------- public helpers ---------------- */

  /// Flux de connexion continu
  Stream<User?> authState() => _auth.authStateChanges();

  /*--------- wrappers statiques pour ton UI existante ---------*/
  static Future<UserCredential> signIn(String email, String password) =>
      _instance._auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  static Future<UserCredential> signUp(String email, String password) =>
      _instance._auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

  static Future<void> signOut() => _instance._auth.signOut();

  static String? get currentUid => _instance._auth.currentUser?.uid;
}
