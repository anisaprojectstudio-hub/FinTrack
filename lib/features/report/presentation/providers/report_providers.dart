import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';
import '../../domain/entities/report_period.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/usecases/calculate_report_summary_usecase.dart';

const _calculateReportSummary = CalculateReportSummaryUseCase();

/// Toggle Mingguan/Bulanan — default Bulanan.
final reportPeriodProvider =
    StateProvider<ReportPeriod>((ref) => ReportPeriod.monthly);

/// Report tidak punya stream Firestore sendiri — reuse
/// [allTransactionsStreamProvider] dari fitur transaction (sama seperti
/// Dashboard), diproses lewat use case murni untuk periode yang dipilih.
/// Catatan: dibatasi oleh limit [allTransactionsStreamProvider] (500 data
/// terbaru) — cukup untuk laporan mingguan/bulanan skala personal.
final reportSummaryProvider = Provider<ReportSummary>((ref) {
  final period = ref.watch(reportPeriodProvider);
  final transactionsAsync = ref.watch(allTransactionsStreamProvider);

  if (!transactionsAsync.hasValue) return ReportSummary.empty();

  return _calculateReportSummary(
    transactions: transactionsAsync.value!,
    period: period,
    referenceDate: DateTime.now(),
  );
});
