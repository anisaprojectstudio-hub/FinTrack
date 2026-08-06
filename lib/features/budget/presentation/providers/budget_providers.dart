import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/month_key_formatter.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';
import '../../data/datasources/budget_remote_data_source.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/budget_progress.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/usecases/add_budget_usecase.dart';
import '../../domain/usecases/calculate_budget_progress_usecase.dart';
import '../../domain/usecases/delete_budget_usecase.dart';
import '../../domain/usecases/update_budget_usecase.dart';
import '../../domain/usecases/watch_budgets_usecase.dart';

const _calculateBudgetProgress = CalculateBudgetProgressUseCase();

// --- Dependency injection ---

final budgetRemoteDataSourceProvider = Provider<BudgetRemoteDataSource>((ref) {
  return BudgetRemoteDataSource(firestore: FirebaseFirestore.instance);
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(ref.watch(budgetRemoteDataSourceProvider));
});

final watchBudgetsUseCaseProvider =
    Provider((ref) => WatchBudgetsUseCase(ref.watch(budgetRepositoryProvider)));
final addBudgetUseCaseProvider =
    Provider((ref) => AddBudgetUseCase(ref.watch(budgetRepositoryProvider)));
final updateBudgetUseCaseProvider =
    Provider((ref) => UpdateBudgetUseCase(ref.watch(budgetRepositoryProvider)));
final deleteBudgetUseCaseProvider =
    Provider((ref) => DeleteBudgetUseCase(ref.watch(budgetRepositoryProvider)));

// --- Bulan aktif (reuse selectedMonthProvider dari fitur transaction agar
// filter bulan di Budget & Transaksi selalu sinkron) ---

final selectedMonthKeyProvider = Provider<String>((ref) {
  return MonthKeyFormatter.format(ref.watch(selectedMonthProvider));
});

// --- Stream budget bulan aktif ---

final budgetsStreamProvider = StreamProvider<List<BudgetEntity>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final month = ref.watch(selectedMonthKeyProvider);
  if (userId == null) return const Stream.empty();
  return ref
      .watch(watchBudgetsUseCaseProvider)
      .call(userId: userId, month: month);
});

/// Progress tiap budget — reuse [transactionsStreamProvider] (bulan aktif)
/// yang sudah ada dari fitur transaction, tidak ada query tambahan.
final budgetProgressListProvider = Provider<List<BudgetProgress>>((ref) {
  final budgets = ref.watch(budgetsStreamProvider).valueOrNull ?? [];
  final transactions = ref.watch(transactionsStreamProvider).valueOrNull ?? [];
  return _calculateBudgetProgress(
      budgets: budgets, monthTransactions: transactions);
});

// --- Controller untuk form Tambah/Ubah Budget ---

class BudgetFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> add(BudgetEntity budget) async {
    state = const AsyncLoading();
    final existing = ref.read(budgetsStreamProvider).valueOrNull ?? [];
    final result = await ref
        .read(addBudgetUseCaseProvider)
        .call(budget, existingBudgetsThisMonth: existing);
    return result.when(
      success: (_) {
        state = const AsyncData(null);
        return true;
      },
      failure: (f) {
        state = AsyncError(f.message, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> updateBudget(BudgetEntity budget) async {
    state = const AsyncLoading();
    final result = await ref.read(updateBudgetUseCaseProvider).call(budget);
    return result.when(
      success: (_) {
        state = const AsyncData(null);
        return true;
      },
      failure: (f) {
        state = AsyncError(f.message, StackTrace.current);
        return false;
      },
    );
  }
}

final budgetFormControllerProvider =
    AsyncNotifierProvider<BudgetFormController, void>(BudgetFormController.new);

// --- Controller hapus budget ---

class DeleteBudgetController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> delete(String budgetId) async {
    final result = await ref.read(deleteBudgetUseCaseProvider).call(budgetId);
    return result.when(success: (_) => true, failure: (_) => false);
  }
}

final deleteBudgetControllerProvider =
    AsyncNotifierProvider<DeleteBudgetController, void>(
        DeleteBudgetController.new);
