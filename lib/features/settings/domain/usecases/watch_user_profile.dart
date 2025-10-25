import 'package:money_tracker/features/settings/domain/entities/user_profile.dart';
import 'package:money_tracker/features/settings/domain/repositories/account_settings_repository.dart';

class WatchUserProfile {
  const WatchUserProfile(this._repository);

  final AccountSettingsRepository _repository;

  Stream<UserProfile?> call() => _repository.watchUserProfile();
}
