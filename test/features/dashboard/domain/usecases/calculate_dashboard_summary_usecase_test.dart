import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/dashboard/domain/usecases/calculate_dashboard_summary_usecase.dart';
import 'package:fintrack/features/transaction/domain/entities/transaction_entity.dart';

TransactionEntity _tx({
  required double amount,
  required TransactionType type,
  required String category,
  required DateTime date,
}) {
  return TransactionEntity(
    id: 'id',
    userId: 'user1',
    amount: amount,
    type: type,
    category: category,
    date: date,
  );
}

void main() {
  const useCase = CalculateDashboardSummaryUseCase();

  group('CalculateDashboardSummaryUseCase', () {
    test(
        'totalBalance = total income - total expense dari SEMUA transaksi (lintas bulan)',
        () {
      final all = [
        _tx(
            amount: 1000000,
            type: TransactionType.income,
            category: 'Salary',
            date: DateTime(2026, 7, 1)),
        _tx(
            amount: 200000,
            type: TransactionType.expense,
            category: 'Food',
            date: DateTime(2026, 7, 5)),
        _tx(
            amount: 500000,
            type: TransactionType.income,
            category: 'Business',
            date: DateTime(2026, 8, 1)),
      ];

      final summary =
          useCase(allTransactions: all, monthTransactions: const []);

      expect(summary.totalBalance, 1300000);
    });

    test('monthIncome & monthExpense hanya dihitung dari monthTransactions',
        () {
      final month = [
        _tx(
            amount: 500000,
            type: TransactionType.income,
            category: 'Salary',
            date: DateTime(2026, 8, 1)),
        _tx(
            amount: 100000,
            type: TransactionType.expense,
            category: 'Food',
            date: DateTime(2026, 8, 2)),
        _tx(
            amount: 50000,
            type: TransactionType.expense,
            category: 'Transportation',
            date: DateTime(2026, 8, 3)),
      ];

      final summary =
          useCase(allTransactions: const [], monthTransactions: month);

      expect(summary.monthIncome, 500000);
      expect(summary.monthExpense, 150000);
    });

    test('expenseByCategory terurut dari terbesar dengan persentase yang benar',
        () {
      final month = [
        _tx(
            amount: 300000,
            type: TransactionType.expense,
            category: 'Food',
            date: DateTime(2026, 8, 1)),
        _tx(
            amount: 100000,
            type: TransactionType.expense,
            category: 'Transportation',
            date: DateTime(2026, 8, 2)),
      ];

      final summary =
          useCase(allTransactions: const [], monthTransactions: month);

      expect(summary.expenseByCategory.first.category, 'Food');
      expect(summary.expenseByCategory.first.percentage, closeTo(75, 0.01));
      expect(summary.expenseByCategory.last.percentage, closeTo(25, 0.01));
    });

    test(
        'tidak ada pengeluaran -> expenseByCategory kosong, tidak error pembagian nol',
        () {
      final summary =
          useCase(allTransactions: const [], monthTransactions: const []);

      expect(summary.expenseByCategory, isEmpty);
      expect(summary.monthExpense, 0);
    });
  });
}
