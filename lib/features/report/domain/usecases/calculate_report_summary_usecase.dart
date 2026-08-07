import '../../../transaction/domain/entities/transaction_entity.dart';
import '../entities/report_period.dart';
import '../entities/report_summary.dart';

/// Logic bisnis murni — tidak menyentuh Firebase, dihitung dari data
/// transaksi yang sudah di-fetch (sesuai keputusan Tahap 2).
class CalculateReportSummaryUseCase {
  const CalculateReportSummaryUseCase();

  ReportSummary call({
    required List<TransactionEntity> transactions,
    required ReportPeriod period,
    required DateTime referenceDate,
  }) {
    final range = _rangeFor(period, referenceDate);
    final inRange = transactions
        .where(
            (t) => !t.date.isBefore(range.start) && !t.date.isAfter(range.end))
        .toList();

    double income = 0;
    double expense = 0;
    final categoryTotals = <String, double>{};

    for (final t in inRange) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
        categoryTotals.update(t.category, (v) => v + t.amount,
            ifAbsent: () => t.amount);
      }
    }

    final breakdown = categoryTotals.entries
        .map((e) => CategoryBreakdownItem(
              category: e.key,
              total: e.value,
              percentage: expense == 0 ? 0 : (e.value / expense) * 100,
            ))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return ReportSummary(
      totalIncome: income,
      totalExpense: expense,
      categoryBreakdown: breakdown,
      trend: _buildTrend(period, range, inRange),
    );
  }

  ({DateTime start, DateTime end}) _rangeFor(
      ReportPeriod period, DateTime reference) {
    if (period == ReportPeriod.weekly) {
      // Minggu berjalan: Senin s.d. Minggu (konvensi Indonesia).
      final start = DateTime(reference.year, reference.month, reference.day)
          .subtract(Duration(days: reference.weekday - 1));
      final end = start
          .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      return (start: start, end: end);
    }
    final start = DateTime(reference.year, reference.month, 1);
    final end = DateTime(reference.year, reference.month + 1, 1)
        .subtract(const Duration(seconds: 1));
    return (start: start, end: end);
  }

  List<TrendPoint> _buildTrend(
    ReportPeriod period,
    ({DateTime start, DateTime end}) range,
    List<TransactionEntity> inRange,
  ) {
    if (period == ReportPeriod.weekly) {
      const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      final totals = List<double>.filled(7, 0);
      for (final t in inRange) {
        if (t.type != TransactionType.expense) continue;
        final dayIndex = t.date.difference(range.start).inDays;
        if (dayIndex >= 0 && dayIndex < 7) totals[dayIndex] += t.amount;
      }
      return [
        for (var i = 0; i < 7; i++)
          TrendPoint(label: labels[i], expense: totals[i])
      ];
    }

    // Bulanan: kelompokkan per minggu-ke berapa dalam bulan (maks 5 bucket)
    // supaya grafik tetap ringkas — bukan 31 batang harian yang padat
    // (sesuai prinsip UX Tahap 4: satu insight jelas, bukan grafik super detail).
    final totals = List<double>.filled(5, 0);
    for (final t in inRange) {
      if (t.type != TransactionType.expense) continue;
      final weekIndex = ((t.date.day - 1) / 7).floor().clamp(0, 4);
      totals[weekIndex] += t.amount;
    }
    return [
      for (var i = 0; i < 5; i++)
        TrendPoint(label: 'M${i + 1}', expense: totals[i])
    ];
  }
}
