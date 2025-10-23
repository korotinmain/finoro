import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/core/providers/auth_providers.dart';
import 'package:money_tracker/features/money/domain/transaction.dart';

/// Repository interface for transaction operations
abstract class ITransactionRepository {
  Stream<List<MoneyTx>> watchUserTransactions(String userId);
  Future<void> addTransaction(String userId, MoneyTx transaction);
  Future<void> updateTransaction(String userId, MoneyTx transaction);
  Future<void> deleteTransaction(String userId, String transactionId);
  Future<List<MoneyTx>> getTransactionsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  );
}

/// Firestore implementation of transaction repository
class FirestoreTransactionRepository implements ITransactionRepository {
  final FirebaseFirestore _firestore;

  FirestoreTransactionRepository([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _getUserTransactionsCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  @override
  Stream<List<MoneyTx>> watchUserTransactions(String userId) {
    return _getUserTransactionsCollection(
      userId,
    ).orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MoneyTx.fromJson(data);
      }).toList();
    });
  }

  @override
  Future<void> addTransaction(String userId, MoneyTx transaction) async {
    await _getUserTransactionsCollection(
      userId,
    ).doc(transaction.id).set(transaction.toJson());
  }

  @override
  Future<void> updateTransaction(String userId, MoneyTx transaction) async {
    await _getUserTransactionsCollection(
      userId,
    ).doc(transaction.id).update(transaction.toJson());
  }

  @override
  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _getUserTransactionsCollection(userId).doc(transactionId).delete();
  }

  @override
  Future<List<MoneyTx>> getTransactionsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final snapshot =
        await _getUserTransactionsCollection(userId)
            .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
            .where('date', isLessThanOrEqualTo: end.toIso8601String())
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return MoneyTx.fromJson(data);
    }).toList();
  }
}

/// Provider for transaction repository
final transactionRepositoryProvider = Provider<ITransactionRepository>((ref) {
  return FirestoreTransactionRepository();
});

/// Provider for watching user transactions
final userTransactionsProvider = StreamProvider<List<MoneyTx>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchUserTransactions(user.uid);
});

/// Provider for transaction statistics
final transactionStatsProvider = Provider<TransactionStats>((ref) {
  final transactions = ref.watch(userTransactionsProvider);

  return transactions.when(
    data: (txList) {
      double totalIncome = 0;
      double totalExpense = 0;

      for (final tx in txList) {
        if (tx.isIncome) {
          totalIncome += tx.amount;
        } else {
          totalExpense += tx.amount;
        }
      }

      return TransactionStats(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: totalIncome - totalExpense,
        transactionCount: txList.length,
      );
    },
    loading: () => const TransactionStats(),
    error: (_, __) => const TransactionStats(),
  );
});

/// Data class for transaction statistics
class TransactionStats {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int transactionCount;

  const TransactionStats({
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.balance = 0,
    this.transactionCount = 0,
  });
}
