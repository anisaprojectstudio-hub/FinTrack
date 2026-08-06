import '../../../../shared/models/result.dart';
import '../entities/budget_entity.dart';

abstract class BudgetRepository {
  /// Semua budget milik [userId] di bulan [month] (format "YYYY-MM").
  Stream<List<BudgetEntity>> watchBudgets(
      {required String userId, required String month});

  Future<Result<void>> addBudget(BudgetEntity budget);

  Future<Result<void>> updateBudget(BudgetEntity budget);

  Future<Result<void>> deleteBudget(String budgetId);
}
