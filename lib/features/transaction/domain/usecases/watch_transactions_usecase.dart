import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class WatchTransactionsUseCase {
  final TransactionRepository repository;
  const WatchTransactionsUseCase(this.repository);

  Stream<List<TransactionEntity>> call(
      {required String userId, required DateTime month}) {
    return repository.watchTransactions(userId: userId, month: month);
  }
}
