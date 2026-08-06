import '../../../../shared/models/result.dart';
import '../repositories/budget_repository.dart';

class DeleteBudgetUseCase {
  final BudgetRepository repository;
  const DeleteBudgetUseCase(this.repository);

  Future<Result<void>> call(String budgetId) =>
      repository.deleteBudget(budgetId);
}
