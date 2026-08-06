import 'budget_entity.dart';

/// Hasil perhitungan progress budget — TIDAK disimpan di Firestore
/// (sesuai keputusan Tahap 3: selalu dihitung ulang dari transaksi
/// supaya tidak pernah basi).
class BudgetProgress {
  final BudgetEntity budget;
  final double spent;
  final double percentage; // bisa >100 kalau over budget

  const BudgetProgress(
      {required this.budget, required this.spent, required this.percentage});

  double get remaining => budget.limitAmount - spent;
  bool get isOverBudget => percentage > 100;
}
