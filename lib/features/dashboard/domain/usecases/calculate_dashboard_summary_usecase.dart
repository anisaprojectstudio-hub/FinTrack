import '../../../transaction/domain/entities/transaction_entity.dart';
import '../entities/dashboard_summary.dart';

/// Logic bisnis murni — tidak menyentuh Firebase sama sekali, jadi bisa
/// di-unit-test langsung dengan list transaksi biasa (sesuai Tahap 2).
class CalculateDashboardSummaryUseCase {
  const CalculateDashboardSummaryUseCase();

  DashboardSummary call({
    required List<TransactionEntity> allTransactions,
    required List<TransactionEntity> monthTransactions,
  }) {
    double totalBalance = 0;
    for (final t in allTransactions) {
      totalBalance += t.type == TransactionType.income ? t.amount : -t.amount;
    }

    double monthIncome = 0;
    double monthExpense = 0;
    final categoryTotals = <String, double>{};

    for (final t in monthTransactions) {
      if (t.type == TransactionType.income) {
        monthIncome += t.amount;
      } else {
        monthExpense += t.amount;
        categoryTotals.update(t.category, (v) => v + t.amount,
            ifAbsent: () => t.amount);
      }
    }

    final expenseByCategory = categoryTotals.entries
        .map((e) => CategoryExpense(
              category: e.key,
              total: e.value,
              percentage:
                  monthExpense == 0 ? 0 : (e.value / monthExpense) * 100,
            ))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return DashboardSummary(
      totalBalance: totalBalance,
      monthIncome: monthIncome,
      monthExpense: monthExpense,
      expenseByCategory: expenseByCategory,
    );
  }
}
