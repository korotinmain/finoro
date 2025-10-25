import 'package:money_tracker/features/auth/domain/repositories/auth_repository.dart';

class SendEmailVerification {
  const SendEmailVerification(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.sendEmailVerification();
}
