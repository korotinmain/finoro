import 'package:money_tracker/features/settings/domain/repositories/account_settings_repository.dart';

class SignOutUser {
  const SignOutUser(this._repository);

  final AccountSettingsRepository _repository;

  Future<void> call() => _repository.signOut();
}
