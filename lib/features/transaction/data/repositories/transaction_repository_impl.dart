import '../../../../core/errors/failure.dart';
import '../../../../shared/models/result.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _remote;
  TransactionRepositoryImpl(this._remote);

  @override
  Stream<List<TransactionEntity>> watchTransactions({
    required String userId,
    required DateTime month,
  }) {
    return _remote.watchTransactions(userId: userId, month: month);
  }

  @override
  Stream<List<TransactionEntity>> watchAllTransactions({
    required String userId,
    int limit = 500,
  }) {
    return _remote.watchAllTransactions(userId: userId, limit: limit);
  }

  @override
  Future<Result<void>> addTransaction(TransactionEntity transaction) async {
    try {
      await _remote.addTransaction(TransactionModel.fromEntity(transaction));
      return const Success(null);
    } catch (_) {
      return const ResultFailure(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> updateTransaction(TransactionEntity transaction) async {
    try {
      await _remote.updateTransaction(TransactionModel.fromEntity(transaction));
      return const Success(null);
    } catch (_) {
      return const ResultFailure(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> deleteTransaction(String transactionId) async {
    try {
      await _remote.deleteTransaction(transactionId);
      return const Success(null);
    } catch (_) {
      return const ResultFailure(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> restoreTransaction(TransactionEntity transaction) async {
    try {
      await _remote
          .restoreTransaction(TransactionModel.fromEntity(transaction));
      return const Success(null);
    } catch (_) {
      return const ResultFailure(NetworkFailure());
    }
  }
}
