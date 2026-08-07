import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/report/domain/entities/report_period.dart';
import 'package:fintrack/features/report/domain/usecases/calculate_report_summary_usecase.dart';
import 'package:fintrack/features/transaction/domain/entities/transaction_entity.dart';

TransactionEntity _tx(DateTime date, TransactionType type, double amount,
    [String category = 'Food']) {
  return TransactionEntity(
      id: 'id',
      userId: 'u1',
      amount: amount,
      type: type,
      category: category,
      date: date);
}

void main() {
  const useCase = CalculateReportSummaryUseCase();

  group('CalculateReportSummaryUseCase - periode bulanan', () {
    test('hanya menghitung transaksi di bulan yang sama dengan referenceDate',
        () {
      final transactions = [
        _tx(DateTime(2026, 8, 5), TransactionType.expense, 100000),
        _tx(DateTime(2026, 7, 20), TransactionType.expense,
            999999), // bulan lain, harus diabaikan
      ];

      final summary = useCase(
        transactions: transactions,
        period: ReportPeriod.monthly,
        referenceDate: DateTime(2026, 8, 15),
      );

      expect(summary.totalExpense, 100000);
    });

    test('topCategory mengembalikan kategori dengan total tertinggi', () {
      final transactions = [
        _tx(DateTime(2026, 8, 1), TransactionType.expense, 200000, 'Food'),
        _tx(DateTime(2026, 8, 2), TransactionType.expense, 500000, 'Bills'),
      ];

      final summary = useCase(
        transactions: transactions,
        period: ReportPeriod.monthly,
        referenceDate: DateTime(2026, 8, 15),
      );

      expect(summary.topCategory?.category, 'Bills');
    });
  });

  group('CalculateReportSummaryUseCase - periode mingguan', () {
    test('hanya menghitung transaksi dalam minggu Senin-Minggu yang sama', () {
      // referenceDate Sabtu 15 Agustus 2026 -> minggu berjalan: Senin 10 s.d Minggu 16 Agustus.
      final transactions = [
        _tx(DateTime(2026, 8, 12), TransactionType.expense,
            50000), // dalam minggu itu
        _tx(DateTime(2026, 8, 3), TransactionType.expense,
            999999), // minggu sebelumnya, diabaikan
      ];

      final summary = useCase(
        transactions: transactions,
        period: ReportPeriod.weekly,
        referenceDate: DateTime(2026, 8, 15),
      );

      expect(summary.totalExpense, 50000);
    });
  });

  test('net = totalIncome - totalExpense', () {
    final transactions = [
      _tx(DateTime(2026, 8, 1), TransactionType.income, 1000000),
      _tx(DateTime(2026, 8, 2), TransactionType.expense, 300000),
    ];

    final summary = useCase(
      transactions: transactions,
      period: ReportPeriod.monthly,
      referenceDate: DateTime(2026, 8, 15),
    );

    expect(summary.net, 700000);
  });

  test('data kosong tidak menyebabkan error dan mengembalikan summary nol', () {
    final summary = useCase(
      transactions: const [],
      period: ReportPeriod.monthly,
      referenceDate: DateTime(2026, 8, 15),
    );

    expect(summary.totalIncome, 0);
    expect(summary.totalExpense, 0);
    expect(summary.categoryBreakdown, isEmpty);
    expect(summary.topCategory, isNull);
  });
}
