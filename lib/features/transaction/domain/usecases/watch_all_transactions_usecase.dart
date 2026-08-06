import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class WatchAllTransactionsUseCase {
  final TransactionRepository repository;
  const WatchAllTransactionsUseCase(this.repository);

  Stream<List<TransactionEntity>> call(
      {required String userId, int limit = 500}) {
    return repository.watchAllTransactions(userId: userId, limit: limit);
  }
}
