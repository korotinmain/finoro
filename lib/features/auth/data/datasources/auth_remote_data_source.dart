import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:money_tracker/core/errors/auth_exception.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: const ['email']);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User cancelled the sign-in flow.
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw const AuthException('Missing Google ID token');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException('Google sign-in failed', e.code);
    } catch (e) {
      throw AuthException('Unexpected error during Google sign-in', '$e');
    }
  }

  Future<User?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = appleCredential.identityToken;
      if (idToken == null) {
        throw const AuthException('Missing Apple ID token');
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: idToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user;

      if (user != null && user.displayName == null) {
        final given = appleCredential.givenName ?? '';
        final family = appleCredential.familyName ?? '';
        final displayName = '${given.trim()} ${family.trim()}'.trim();
        if (displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException('Apple sign-in failed', e.code);
    } on SignInWithAppleNotSupportedException {
      throw const AuthException('Apple Sign-In is not supported on this device');
    } catch (e) {
      throw AuthException('Unexpected error during Apple sign-in', '$e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<User?> reloadCurrentUser() async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException('No user logged in');
    }

    try {
      await user.reload();
      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException('User reload failed', e.code);
    } catch (e) {
      throw AuthException('Unexpected error during user reload', '$e');
    }
  }
}
