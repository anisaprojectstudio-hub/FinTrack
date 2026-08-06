import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../models/transaction_model.dart';

class TransactionRemoteDataSource {
  final FirebaseFirestore _firestore;
  TransactionRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirestorePaths.transactions);

  /// Query utama sesuai pola Tahap 3: filter userId + range tanggal bulan,
  /// urut terbaru dulu — butuh composite index (userId + date).
  Stream<List<TransactionModel>> watchTransactions({
    required String userId,
    required DateTime month,
  }) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    return _col
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TransactionModel.fromJson(d.data(), d.id))
            .toList());
  }

  Future<void> addTransaction(TransactionModel transaction) {
    return _col.add(transaction.toJson());
  }

  Future<void> updateTransaction(TransactionModel transaction) {
    return _col.doc(transaction.id).update(transaction.toJson(isUpdate: true));
  }

  Future<void> deleteTransaction(String id) {
    return _col.doc(id).delete();
  }

  /// Menulis ulang dokumen dengan ID yang sama — dipakai untuk fitur Undo.
  Future<void> restoreTransaction(TransactionModel transaction) {
    return _col.doc(transaction.id).set(transaction.toJson());
  }
}
