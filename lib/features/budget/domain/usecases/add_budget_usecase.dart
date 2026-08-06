import '../../../../core/errors/failure.dart';
import '../../../../shared/models/result.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class AddBudgetUseCase {
  final BudgetRepository repository;
  const AddBudgetUseCase(this.repository);

  /// [existingBudgetsThisMonth] dioper dari provider yang sudah watch data
  /// bulan aktif — dipakai untuk mencegah duplikasi kategori+bulan
  /// (aturan yang ditetapkan di Tahap 3).
  Future<Result<void>> call(
    BudgetEntity budget, {
    required List<BudgetEntity> existingBudgetsThisMonth,
  }) {
    if (budget.limitAmount <= 0) {
      return Future.value(const ResultFailure(
          ValidationFailure('Limit budget harus lebih dari 0')));
    }
    final alreadyExists =
        existingBudgetsThisMonth.any((b) => b.category == budget.category);
    if (alreadyExists) {
      return Future.value(
        const ResultFailure(
            ValidationFailure('Kategori ini sudah punya budget bulan ini')),
      );
    }
    return repository.addBudget(budget);
  }
}
