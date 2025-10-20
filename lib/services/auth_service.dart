// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapCodeToMessage(e.code));
    } catch (_) {
      throw AuthException('Unexpected error. Please try again.');
    }
  }

  Future<void> sendPasswordReset(String email) async {
    final actionCodeSettings = ActionCodeSettings(
      url: 'https://moneytracker-5c1e6.web.app/auth/action',
      handleCodeInApp: false,
      androidPackageName: 'com.korotindenys.moneyTracker',
      androidInstallApp: false,
      androidMinimumVersion: '21',
      iOSBundleId: 'com.korotindenys.moneyTracker',
    );
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
        actionCodeSettings: actionCodeSettings,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapCodeToMessage(e.code));
    } catch (_) {
      throw AuthException('Unexpected error. Please try again.');
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<User?> signUp(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapSignUpCode(e.code));
    } catch (_) {
      throw AuthException('Unexpected error. Please try again.');
    }
  }

  String _mapSignUpCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email already in use.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return 'Could not create account.';
    }
  }

  String _mapCodeToMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'Authentication failed.';
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
