import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Service d'authentification centralisé
/// Permet de gérer l'inscription, la connexion, la déconnexion et les providers externes (Google / Apple).
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔁 Stream de l’état d’authentification de l’utilisateur
  static Stream<User?> get userStream => _auth.authStateChanges();

  /// 👤 Utilisateur connecté actuel
  static User? get currentUser => _auth.currentUser;

  /// ✉️ Inscription avec email & mot de passe
  static Future<User?> signUp(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  /// 🔐 Connexion avec email & mot de passe
  static Future<User?> signIn(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  /// 🔓 Déconnexion complète
  static Future<void> signOut() async {
    await GoogleSignIn().signOut(); // Déconnexion Google aussi
    await _auth.signOut();
  }

  /// 🔐 Connexion avec Google
  static Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Erreur Google Sign-In: $e");
      return null;
    }
  }

  /// 🍏 Connexion avec Apple (iOS uniquement)
  static Future<User?> signInWithApple() async {
    if (!Platform.isIOS) return null;

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      return userCredential.user;
    } catch (e) {
      print("Erreur Apple Sign-In: $e");
      return null;
    }
  }
}
