import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:money_tracker/features/money/data/transaction_repository.dart';
import 'package:money_tracker/features/money/domain/entities/transaction_summary.dart';
import 'package:money_tracker/features/money/domain/transaction.dart';
import 'package:money_tracker/features/money/domain/transaction_repository.dart';
import 'package:money_tracker/features/money/domain/usecases/add_transaction.dart';
import 'package:money_tracker/features/money/domain/usecases/calculate_transaction_summary.dart';
import 'package:money_tracker/features/money/domain/usecases/delete_transaction.dart';
import 'package:money_tracker/features/money/domain/usecases/watch_transactions.dart';

final moneyTransactionRepositoryProvider =
    Provider<TransactionRepository>((ref) {
  return FirestoreTransactionRepository();
});

final watchTransactionsUseCaseProvider = Provider<WatchTransactions>((ref) {
  return WatchTransactions(ref.watch(moneyTransactionRepositoryProvider));
});

final addTransactionUseCaseProvider = Provider<AddTransaction>((ref) {
  return AddTransaction(ref.watch(moneyTransactionRepositoryProvider));
});

final deleteTransactionUseCaseProvider = Provider<DeleteTransaction>((ref) {
  return DeleteTransaction(ref.watch(moneyTransactionRepositoryProvider));
});

final calculateTransactionSummaryUseCaseProvider =
    Provider<CalculateTransactionSummary>((ref) {
  return const CalculateTransactionSummary();
});

final userTransactionsProvider =
    StreamProvider.autoDispose<List<MoneyTx>>((ref) {
  final user = ref.watch(currentAuthUserProvider);
  if (user == null) {
    return Stream.value(const <MoneyTx>[]);
  }

  final watch = ref.watch(watchTransactionsUseCaseProvider);
  return watch(user.uid);
});

final transactionSummaryProvider = Provider<TransactionSummary>((ref) {
  final calculator = ref.watch(calculateTransactionSummaryUseCaseProvider);
  final transactions = ref.watch(userTransactionsProvider);

  return transactions.maybeWhen(
    data: calculator.call,
    orElse: () => TransactionSummary.empty,
  );
});
