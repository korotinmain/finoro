import 'package:money_tracker/features/money/domain/entities/transaction_summary.dart';
import 'package:money_tracker/features/money/domain/transaction.dart';

class CalculateTransactionSummary {
  const CalculateTransactionSummary();

  TransactionSummary call(List<MoneyTx> transactions) {
    double income = 0;
    double expense = 0;

    for (final tx in transactions) {
      if (tx.isIncome) {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }

    return TransactionSummary(
      totalIncome: income,
      totalExpense: expense,
      count: transactions.length,
    );
  }
}
