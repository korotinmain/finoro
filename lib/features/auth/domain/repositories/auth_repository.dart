import 'package:money_tracker/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> watchAuthUser();
  AuthUser? get currentUser;
  Future<AuthUser?> signInWithGoogle();
  Future<AuthUser?> signInWithApple();
  Future<void> signOut();
  Future<AuthUser?> reloadCurrentUser();
}
