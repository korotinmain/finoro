import 'package:money_tracker/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> watchAuthUser();
  AuthUser? get currentUser;
  Future<AuthUser?> signIn({
    required String email,
    required String password,
  });
  Future<AuthUser?> signUp({
    required String email,
    required String password,
  });
  Future<void> sendPasswordReset(String email);
  Future<void> sendEmailVerification();
  Future<void> updateDisplayName(String displayName);
  Future<void> signOut();
  Future<AuthUser?> reloadCurrentUser();
}
