import 'package:money_tracker/features/auth/domain/entities/auth_user.dart';
import 'package:money_tracker/features/auth/domain/repositories/auth_repository.dart';

class SignInWithApple {
  const SignInWithApple(this._repository);

  final AuthRepository _repository;

  Future<AuthUser?> call() => _repository.signInWithApple();
}
