class TransactionSummary {
  const TransactionSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.count,
  });

  final double totalIncome;
  final double totalExpense;
  final int count;

  double get balance => totalIncome - totalExpense;

  static const empty = TransactionSummary(
    totalIncome: 0,
    totalExpense: 0,
    count: 0,
  );
}
