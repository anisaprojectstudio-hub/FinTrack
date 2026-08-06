import '../../../transaction/domain/entities/transaction_entity.dart';
import '../entities/budget_entity.dart';
import '../entities/budget_progress.dart';

/// Logic bisnis murni — tidak menyentuh Firebase, dihitung dari data
/// transaksi yang sudah ada (sesuai keputusan Tahap 2 & Tahap 3:
/// progress budget TIDAK disimpan sebagai field statis).
class CalculateBudgetProgressUseCase {
  const CalculateBudgetProgressUseCase();

  List<BudgetProgress> call({
    required List<BudgetEntity> budgets,
    required List<TransactionEntity> monthTransactions,
  }) {
    return budgets.map((budget) {
      final spent = monthTransactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.category == budget.category)
          .fold(0.0, (sum, t) => sum + t.amount);
      final percentage =
          budget.limitAmount == 0 ? 0.0 : (spent / budget.limitAmount) * 100;
      return BudgetProgress(
          budget: budget, spent: spent, percentage: percentage);
    }).toList();
  }
}
