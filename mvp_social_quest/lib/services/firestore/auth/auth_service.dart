import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// 🔐 Service d’authentification multi-providers (email, Google, Apple).
class AuthService {
  static final _auth = FirebaseAuth.instance;

  /// Flux de l’état d’authentification.
  static Stream<User?> get userStream => _auth.authStateChanges();

  /// Utilisateur courant (null si non connecté).
  static User? get currentUser => _auth.currentUser;

  /// Inscription avec email / mot de passe.
  static Future<User?> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /// Connexion email / mot de passe.
  static Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /// Déconnexion (inclut Google Sign-Out).
  static Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  /// Connexion avec Google.
  static Future<User?> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    return cred.user;
  }

  /// Connexion Apple (iOS uniquement).
  static Future<User?> signInWithApple() async {
    if (!Platform.isIOS) return null;
    final appleCred = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final oauth = OAuthProvider('apple.com').credential(
      idToken: appleCred.identityToken,
      accessToken: appleCred.authorizationCode,
    );
    final cred = await _auth.signInWithCredential(oauth);
    return cred.user;
  }
}
