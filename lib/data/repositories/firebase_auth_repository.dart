import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:money_tracker/core/constants/app_strings.dart';
import 'package:money_tracker/core/errors/auth_error_mapper.dart';
import 'package:money_tracker/core/errors/auth_exception.dart';
import 'package:money_tracker/core/interfaces/auth_repository.dart';

/// Firebase implementation of AuthRepository
/// Singleton pattern for consistent instance across app
class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth _auth;

  // Private constructor for singleton
  FirebaseAuthRepository._internal(this._auth);

  // Singleton instance
  static final FirebaseAuthRepository _instance =
      FirebaseAuthRepository._internal(FirebaseAuth.instance);

  // Factory constructor returns singleton instance
  factory FirebaseAuthRepository() => _instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException('Sign in failed', e.code);
    } catch (e) {
      throw const AuthException('Unexpected error during sign in');
    }
  }

  @override
  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException('Sign up failed', e.code);
    } catch (e) {
      throw const AuthException('Unexpected error during sign up');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final actionCodeSettings = ActionCodeSettings(
      url: AppStrings.actionCodeUrl,
      androidPackageName: AppStrings.androidPackageName,
      androidMinimumVersion: AppStrings.androidMinVersion,
      iOSBundleId: AppStrings.iosBundleId,
    );

    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
        actionCodeSettings: actionCodeSettings,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException('Password reset failed', e.code);
    } catch (e) {
      throw const AuthException('Unexpected error during password reset');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException('No user logged in');
    }
    await user.sendEmailVerification();
  }

  @override
  Future<void> reloadUser() async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException('No user logged in');
    }
    await user.reload();
  }
}

/// Extension to convert AuthException to localized message
extension AuthExceptionLocalization on AuthException {
  String toLocalizedMessage(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (code == null) return message;

    // Determine which mapper to use based on the message
    if (message.contains('Sign in')) {
      return AuthErrorMapper.mapSignInError(code!, t);
    } else if (message.contains('Sign up')) {
      return AuthErrorMapper.mapSignUpError(code!, t);
    } else if (message.contains('Password reset')) {
      return AuthErrorMapper.mapPasswordResetError(code!, t);
    }

    return t.errUnexpected;
  }
}
