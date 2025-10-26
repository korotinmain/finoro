import 'transaction.dart';

abstract class TransactionRepository {
  Stream<List<MoneyTx>> watchTransactions(
    String userId, {
    DateTime? from,
    DateTime? to,
  });

  Future<void> addTransaction(String userId, MoneyTx tx);

  Future<void> deleteTransaction(String userId, String transactionId);
}
