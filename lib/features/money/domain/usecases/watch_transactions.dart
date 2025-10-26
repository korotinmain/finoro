import 'package:money_tracker/features/money/domain/transaction.dart';
import 'package:money_tracker/features/money/domain/transaction_repository.dart';

class WatchTransactions {
  const WatchTransactions(this._repository);

  final TransactionRepository _repository;

  Stream<List<MoneyTx>> call(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) {
    return _repository.watchTransactions(userId, from: from, to: to);
  }
}
