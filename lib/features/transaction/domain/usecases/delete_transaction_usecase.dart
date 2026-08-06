import '../../../../shared/models/result.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransactionUseCase {
  final TransactionRepository repository;
  const DeleteTransactionUseCase(this.repository);

  Future<Result<void>> call(String transactionId) =>
      repository.deleteTransaction(transactionId);
}
