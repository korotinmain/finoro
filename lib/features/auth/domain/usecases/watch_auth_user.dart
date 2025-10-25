import 'package:money_tracker/features/auth/domain/entities/auth_user.dart';
import 'package:money_tracker/features/auth/domain/repositories/auth_repository.dart';

class WatchAuthUser {
  const WatchAuthUser(this._repository);

  final AuthRepository _repository;

  Stream<AuthUser?> call() => _repository.watchAuthUser();
}
