import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_tracker/features/money/domain/transaction.dart';
import 'package:money_tracker/features/money/domain/transaction_repository.dart';

class FirestoreTransactionRepository implements TransactionRepository {
  FirestoreTransactionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('transactions');
  }

  @override
  Stream<List<MoneyTx>> watchTransactions(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) {
    Query<Map<String, dynamic>> query =
        _collection(userId).orderBy('date', descending: true);

    if (from != null) {
      query = query.where('date', isGreaterThanOrEqualTo: from.toIso8601String());
    }
    if (to != null) {
      query = query.where('date', isLessThanOrEqualTo: to.toIso8601String());
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return MoneyTx.fromJson({
          ...data,
          'id': data['id'] ?? doc.id,
        });
      }).toList();
    });
  }

  @override
  Future<void> addTransaction(String userId, MoneyTx tx) async {
    final docRef = _collection(userId).doc(tx.id);
    await docRef.set({
      ...tx.toJson(),
      'date': tx.date.toIso8601String(),
    });
  }

  @override
  Future<void> deleteTransaction(String userId, String transactionId) {
    return _collection(userId).doc(transactionId).delete();
  }
}
