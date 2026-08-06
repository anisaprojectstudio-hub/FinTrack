import '../../../../core/errors/failure.dart';
import '../../../../shared/models/result.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class UpdateBudgetUseCase {
  final BudgetRepository repository;
  const UpdateBudgetUseCase(this.repository);

  Future<Result<void>> call(BudgetEntity budget) {
    if (budget.limitAmount <= 0) {
      return Future.value(const ResultFailure(
          ValidationFailure('Limit budget harus lebih dari 0')));
    }
    return repository.updateBudget(budget);
  }
}
