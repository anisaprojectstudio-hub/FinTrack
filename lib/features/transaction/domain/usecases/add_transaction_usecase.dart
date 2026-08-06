import '../../../../core/errors/failure.dart';
import '../../../../shared/models/result.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class AddTransactionUseCase {
  final TransactionRepository repository;
  const AddTransactionUseCase(this.repository);

  Future<Result<void>> call(TransactionEntity transaction) {
    if (transaction.amount <= 0) {
      return Future.value(
          const ResultFailure(ValidationFailure('Nominal harus lebih dari 0')));
    }
    return repository.addTransaction(transaction);
  }
}
