import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/datasources/transaction_remote_data_source.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/delete_transaction_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';
import '../../domain/usecases/watch_transactions_usecase.dart';

// --- Dependency injection ---

final transactionRemoteDataSourceProvider =
    Provider<TransactionRemoteDataSource>((ref) {
  return TransactionRemoteDataSource(firestore: FirebaseFirestore.instance);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
      ref.watch(transactionRemoteDataSourceProvider));
});

final watchTransactionsUseCaseProvider = Provider((ref) =>
    WatchTransactionsUseCase(ref.watch(transactionRepositoryProvider)));
final addTransactionUseCaseProvider = Provider(
    (ref) => AddTransactionUseCase(ref.watch(transactionRepositoryProvider)));
final updateTransactionUseCaseProvider = Provider((ref) =>
    UpdateTransactionUseCase(ref.watch(transactionRepositoryProvider)));
final deleteTransactionUseCaseProvider = Provider((ref) =>
    DeleteTransactionUseCase(ref.watch(transactionRepositoryProvider)));

// --- User & bulan yang sedang aktif ---

/// UID user yang sedang login — null kalau belum login. Dipakai lintas
/// fitur (transaction, budget, report) untuk query "milik siapa".
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
});

/// Bulan yang sedang dipilih di Transaction List & Budget (default: bulan ini).
class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void setMonth(DateTime month) => state = DateTime(month.year, month.month);
}

final selectedMonthProvider = NotifierProvider<SelectedMonthNotifier, DateTime>(
    SelectedMonthNotifier.new);

// --- Stream transaksi bulan aktif ---

final transactionsStreamProvider =
    StreamProvider<List<TransactionEntity>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final month = ref.watch(selectedMonthProvider);
  if (userId == null) return const Stream.empty();
  return ref
      .watch(watchTransactionsUseCaseProvider)
      .call(userId: userId, month: month);
});

/// Ringkasan total income/expense bulan aktif — dipakai lagi di fase Dashboard.
final monthSummaryProvider = Provider<({double income, double expense})>((ref) {
  final transactions = ref.watch(transactionsStreamProvider).valueOrNull ?? [];
  double income = 0, expense = 0;
  for (final t in transactions) {
    if (t.type == TransactionType.income) {
      income += t.amount;
    } else {
      expense += t.amount;
    }
  }
  return (income: income, expense: expense);
});

// --- Controller untuk form Tambah/Ubah Transaksi ---

class TransactionFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> save(TransactionEntity transaction,
      {required bool isEdit}) async {
    state = const AsyncLoading();
    final result = isEdit
        ? await ref.read(updateTransactionUseCaseProvider).call(transaction)
        : await ref.read(addTransactionUseCaseProvider).call(transaction);
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

final transactionFormControllerProvider =
    AsyncNotifierProvider<TransactionFormController, void>(
        TransactionFormController.new);

// --- Controller untuk hapus + undo ---

class DeleteTransactionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> delete(String transactionId) async {
    final result =
        await ref.read(deleteTransactionUseCaseProvider).call(transactionId);
    return result.when(success: (_) => true, failure: (_) => false);
  }

  Future<void> undo(TransactionEntity transaction) async {
    await ref
        .read(transactionRepositoryProvider)
        .restoreTransaction(transaction);
  }
}

final deleteTransactionControllerProvider =
    AsyncNotifierProvider<DeleteTransactionController, void>(
        DeleteTransactionController.new);
