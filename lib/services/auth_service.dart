// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signIn(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      final t = AppLocalizations.of(context)!;
      throw AuthException(_mapCodeToMessage(t, e.code));
    } catch (_) {
      final t = AppLocalizations.of(context)!;
      throw AuthException(t.errUnexpected);
    }
  }

  Future<void> sendPasswordReset(BuildContext context, String email) async {
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
      final t = AppLocalizations.of(context)!;
      throw AuthException(_mapCodeToMessage(t, e.code));
    } catch (_) {
      final t = AppLocalizations.of(context)!;
      throw AuthException(t.errUnexpected);
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<User?> signUp(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      final t = AppLocalizations.of(context)!;
      throw AuthException(_mapSignUpCode(t, e.code));
    } catch (_) {
      final t = AppLocalizations.of(context)!;
      throw AuthException(t.errUnexpected);
    }
  }

  String _mapSignUpCode(AppLocalizations t, String code) {
    switch (code) {
      case 'email-already-in-use':
        return t.errEmailInUse;
      case 'invalid-email':
        return t.errInvalidEmailFormat;
      case 'operation-not-allowed':
        return t.errOperationNotAllowed;
      case 'weak-password':
        return t.errWeakPassword;
      default:
        return t.errCouldNotCreateAccount;
    }
  }

  String _mapCodeToMessage(AppLocalizations t, String code) {
    switch (code) {
      case 'invalid-email':
        return t.errInvalidEmailFormat;
      case 'user-disabled':
        return t.errAccountDisabled;
      case 'user-not-found':
        return t.errUserNotFound;
      case 'wrong-password':
        return t.errWrongPassword;
      default:
        return t.errAuthFailed;
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
