import 'package:money_tracker/features/auth/domain/repositories/auth_repository.dart';

class UpdateDisplayName {
  const UpdateDisplayName(this._repository);

  final AuthRepository _repository;

  Future<void> call(String displayName) =>
      _repository.updateDisplayName(displayName);
}
