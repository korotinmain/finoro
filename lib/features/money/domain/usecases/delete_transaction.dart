import 'package:money_tracker/features/money/domain/transaction_repository.dart';

class DeleteTransaction {
  const DeleteTransaction(this._repository);

  final TransactionRepository _repository;

  Future<void> call(String userId, String transactionId) {
    return _repository.deleteTransaction(userId, transactionId);
  }
}
