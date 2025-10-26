import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_tracker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:money_tracker/features/auth/domain/entities/auth_user.dart';
import 'package:money_tracker/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Stream<AuthUser?> watchAuthUser() {
    return _remoteDataSource.authStateChanges().map(_mapUser);
  }

  @override
  AuthUser? get currentUser => _mapUser(_remoteDataSource.currentUser);

  @override
  Future<AuthUser?> signInWithGoogle() async {
    final user = await _remoteDataSource.signInWithGoogle();
    return _mapUser(user);
  }

  @override
  Future<AuthUser?> signInWithApple() async {
    final user = await _remoteDataSource.signInWithApple();
    return _mapUser(user);
  }

  @override
  Future<void> signOut() => _remoteDataSource.signOut();

  @override
  Future<AuthUser?> reloadCurrentUser() async {
    final user = await _remoteDataSource.reloadCurrentUser();
    return _mapUser(user);
  }

  AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    final email = user.email ?? 'anonymous@finoro.app';
    return AuthUser(
      uid: user.uid,
      email: email,
      isEmailVerified: user.emailVerified,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
