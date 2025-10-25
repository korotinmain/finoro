import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_tracker/core/interfaces/auth_repository.dart';
import 'package:money_tracker/features/settings/domain/entities/user_profile.dart';
import 'package:money_tracker/features/settings/domain/repositories/account_settings_repository.dart';

class AccountSettingsRepositoryImpl implements AccountSettingsRepository {
  AccountSettingsRepositoryImpl(this._authRepository);

  final IAuthRepository _authRepository;

  @override
  Stream<UserProfile?> watchUserProfile() {
    return _authRepository.authStateChanges.map(_mapUserToProfile);
  }

  @override
  Future<void> signOut() => _authRepository.signOut();

  UserProfile? _mapUserToProfile(User? user) {
    if (user == null) return null;
    final rawDisplayName = user.displayName?.trim();
    final displayName =
        (rawDisplayName != null && rawDisplayName.isNotEmpty)
            ? rawDisplayName
            : user.email?.split('@').first ?? 'anonymous';
    return UserProfile(
      displayName: displayName,
      email: user.email ?? 'anonymous',
      isEmailVerified: user.emailVerified,
    );
  }
}
