import '../../../../core/errors/failure.dart';
import '../../../../shared/models/result.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_remote_data_source.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetRemoteDataSource _remote;
  BudgetRepositoryImpl(this._remote);

  @override
  Stream<List<BudgetEntity>> watchBudgets(
      {required String userId, required String month}) {
    return _remote.watchBudgets(userId: userId, month: month);
  }

  @override
  Future<Result<void>> addBudget(BudgetEntity budget) async {
    try {
      await _remote.addBudget(BudgetModel.fromEntity(budget));
      return const Success(null);
    } catch (_) {
      return const ResultFailure(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> updateBudget(BudgetEntity budget) async {
    try {
      await _remote.updateBudget(BudgetModel.fromEntity(budget));
      return const Success(null);
    } catch (_) {
      return const ResultFailure(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> deleteBudget(String budgetId) async {
    try {
      await _remote.deleteBudget(budgetId);
      return const Success(null);
    } catch (_) {
      return const ResultFailure(NetworkFailure());
    }
  }
}
