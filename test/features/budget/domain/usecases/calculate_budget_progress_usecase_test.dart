import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/budget/domain/entities/budget_entity.dart';
import 'package:fintrack/features/budget/domain/usecases/calculate_budget_progress_usecase.dart';
import 'package:fintrack/features/transaction/domain/entities/transaction_entity.dart';

TransactionEntity _expense(String category, double amount) {
  return TransactionEntity(
    id: 'id',
    userId: 'u1',
    amount: amount,
    type: TransactionType.expense,
    category: category,
    date: DateTime(2026, 8, 1),
  );
}

void main() {
  const useCase = CalculateBudgetProgressUseCase();

  group('CalculateBudgetProgressUseCase', () {
    test('menghitung persentase pemakaian budget dengan benar', () {
      const budgets = [
        BudgetEntity(
            id: 'b1',
            userId: 'u1',
            category: 'Food',
            limitAmount: 1000000,
            month: '2026-08'),
      ];
      final transactions = [_expense('Food', 750000)];

      final result = useCase(budgets: budgets, monthTransactions: transactions);

      expect(result.single.spent, 750000);
      expect(result.single.percentage, closeTo(75, 0.01));
      expect(result.single.isOverBudget, isFalse);
    });

    test('over budget terdeteksi ketika pengeluaran melebihi limit', () {
      const budgets = [
        BudgetEntity(
            id: 'b1',
            userId: 'u1',
            category: 'Food',
            limitAmount: 500000,
            month: '2026-08'),
      ];
      final transactions = [_expense('Food', 600000)];

      final result = useCase(budgets: budgets, monthTransactions: transactions);

      expect(result.single.percentage, greaterThan(100));
      expect(result.single.isOverBudget, isTrue);
    });

    test('transaksi kategori lain tidak ikut dihitung ke budget kategori ini',
        () {
      const budgets = [
        BudgetEntity(
            id: 'b1',
            userId: 'u1',
            category: 'Food',
            limitAmount: 500000,
            month: '2026-08'),
      ];
      final transactions = [_expense('Transportation', 300000)];

      final result = useCase(budgets: budgets, monthTransactions: transactions);

      expect(result.single.spent, 0);
    });

    test('transaksi income tidak ikut dihitung sebagai pemakaian budget', () {
      const budgets = [
        BudgetEntity(
            id: 'b1',
            userId: 'u1',
            category: 'Food',
            limitAmount: 500000,
            month: '2026-08'),
      ];
      final transactions = [
        TransactionEntity(
          id: 'id',
          userId: 'u1',
          amount: 1000000,
          type: TransactionType.income,
          category:
              'Food', // kategori sama, tapi tipe income -> tetap tidak dihitung
          date: DateTime(2026, 8, 1),
        ),
      ];

      final result = useCase(budgets: budgets, monthTransactions: transactions);

      expect(result.single.spent, 0);
    });

    test('beberapa budget dihitung independen satu sama lain', () {
      const budgets = [
        BudgetEntity(
            id: 'b1',
            userId: 'u1',
            category: 'Food',
            limitAmount: 500000,
            month: '2026-08'),
        BudgetEntity(
            id: 'b2',
            userId: 'u1',
            category: 'Bills',
            limitAmount: 300000,
            month: '2026-08'),
      ];
      final transactions = [
        _expense('Food', 250000),
        _expense('Bills', 300000)
      ];

      final result = useCase(budgets: budgets, monthTransactions: transactions);

      final food = result.firstWhere((p) => p.budget.category == 'Food');
      final bills = result.firstWhere((p) => p.budget.category == 'Bills');

      expect(food.percentage, closeTo(50, 0.01));
      expect(bills.percentage, closeTo(100, 0.01));
    });
  });
}
