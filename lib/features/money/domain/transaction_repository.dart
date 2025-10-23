import 'currency.dart';
import 'transaction.dart';

abstract class TransactionRepository {
  Stream<List<MoneyTx>> watch({DateTime? from, DateTime? to, Currency? currency});
  Future<void> add(MoneyTx tx);
  Future<void> remove(String id);
}