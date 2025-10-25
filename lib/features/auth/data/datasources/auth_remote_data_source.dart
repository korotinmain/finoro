import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_tracker/core/constants/app_strings.dart';
import 'package:money_tracker/core/errors/auth_exception.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException('Sign in failed', e.code);
    } catch (_) {
      throw const AuthException('Unexpected error during sign in');
    }
  }

  Future<User?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException('Sign up failed', e.code);
    } catch (_) {
      throw const AuthException('Unexpected error during sign up');
    }
  }

  Future<void> sendPasswordReset(String email) async {
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
    } catch (_) {
      throw const AuthException('Unexpected error during password reset');
    }
  }

  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException('No user logged in');
    }
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException('Email verification failed', e.code);
    } catch (_) {
      throw const AuthException('Unexpected error during email verification');
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException('No user logged in');
    }

    try {
      await user.updateDisplayName(displayName.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException('Profile update failed', e.code);
    } catch (_) {
      throw const AuthException('Unexpected error during profile update');
    }
  }

  Future<void> signOut() => _auth.signOut();

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
    } catch (_) {
      throw const AuthException('Unexpected error during user reload');
    }
  }
}
