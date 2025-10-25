import 'package:money_tracker/features/auth/domain/entities/auth_user.dart';
import 'package:money_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:money_tracker/features/settings/domain/entities/user_profile.dart';
import 'package:money_tracker/features/settings/domain/repositories/account_settings_repository.dart';

class AccountSettingsRepositoryImpl implements AccountSettingsRepository {
  AccountSettingsRepositoryImpl(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Stream<UserProfile?> watchUserProfile() {
    return _authRepository.watchAuthUser().map(_mapUserToProfile);
  }

  @override
  Future<void> signOut() => _authRepository.signOut();

  UserProfile? _mapUserToProfile(AuthUser? user) {
    if (user == null) return null;
    final displayName =
        user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : user.email.split('@').first;
    return UserProfile(
      displayName: displayName,
      email: user.email,
      isEmailVerified: user.isEmailVerified,
    );
  }
}
