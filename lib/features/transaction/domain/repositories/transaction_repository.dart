import '../../../../shared/models/result.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  /// Real-time list transaksi milik [userId] di bulan [month] (hanya
  /// year/month dari parameter ini yang dipakai untuk filter).
  Stream<List<TransactionEntity>> watchTransactions({
    required String userId,
    required DateTime month,
  });

  Future<Result<void>> addTransaction(TransactionEntity transaction);

  Future<Result<void>> updateTransaction(TransactionEntity transaction);

  Future<Result<void>> deleteTransaction(String transactionId);

  /// Dipakai untuk fitur "Undo" setelah hapus — menulis ulang dokumen
  /// dengan ID yang sama seperti sebelum dihapus.
  Future<Result<void>> restoreTransaction(TransactionEntity transaction);
}
