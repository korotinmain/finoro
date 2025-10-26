import 'package:money_tracker/features/money/domain/transaction.dart';
import 'package:money_tracker/features/money/domain/transaction_repository.dart';

class AddTransaction {
  const AddTransaction(this._repository);

  final TransactionRepository _repository;

  Future<void> call(String userId, MoneyTx transaction) {
    return _repository.addTransaction(userId, transaction);
  }
}
