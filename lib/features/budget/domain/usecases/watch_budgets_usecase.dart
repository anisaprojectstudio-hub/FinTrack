import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class WatchBudgetsUseCase {
  final BudgetRepository repository;
  const WatchBudgetsUseCase(this.repository);

  Stream<List<BudgetEntity>> call(
      {required String userId, required String month}) {
    return repository.watchBudgets(userId: userId, month: month);
  }
}
