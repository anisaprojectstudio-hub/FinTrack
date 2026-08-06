import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/usecases/calculate_dashboard_summary_usecase.dart';

const _calculateDashboardSummary = CalculateDashboardSummaryUseCase();

/// Dashboard tidak punya stream Firestore sendiri — cukup pakai ulang
/// [allTransactionsStreamProvider] & [transactionsStreamProvider] dari
/// fitur transaction, lalu diproses lewat use case murni di atas
/// (sesuai keputusan arsitektur Tahap 2).
final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final allAsync = ref.watch(allTransactionsStreamProvider);
  final monthAsync = ref.watch(transactionsStreamProvider);

  if (!allAsync.hasValue || !monthAsync.hasValue) {
    return DashboardSummary.empty();
  }

  return _calculateDashboardSummary(
    allTransactions: allAsync.value!,
    monthTransactions: monthAsync.value!,
  );
});

/// true selama salah satu stream sumber masih loading pertama kali.
final dashboardLoadingProvider = Provider<bool>((ref) {
  final all = ref.watch(allTransactionsStreamProvider);
  final month = ref.watch(transactionsStreamProvider);
  return all.isLoading || month.isLoading;
});
