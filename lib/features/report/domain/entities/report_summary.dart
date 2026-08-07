/// Total pengeluaran satu kategori + persentasenya terhadap total
/// pengeluaran periode berjalan — dasar untuk breakdown list Report.
class CategoryBreakdownItem {
  final String category;
  final double total;
  final double percentage; // 0–100

  const CategoryBreakdownItem(
      {required this.category, required this.total, required this.percentage});
}

/// Satu titik di grafik tren — label bisa berupa hari ("Sen") untuk
/// periode mingguan, atau minggu-ke ("M1") untuk periode bulanan.
class TrendPoint {
  final String label;
  final double expense;

  const TrendPoint({required this.label, required this.expense});
}

/// Ringkasan lengkap yang ditampilkan di halaman Report — dihitung murni
/// dari data transaksi yang sudah ada (Report tidak punya data layer
/// sendiri, sama seperti Dashboard, sesuai keputusan Tahap 2).
class ReportSummary {
  final double totalIncome;
  final double totalExpense;
  final List<CategoryBreakdownItem> categoryBreakdown;
  final List<TrendPoint> trend;

  const ReportSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.categoryBreakdown,
    required this.trend,
  });

  double get net => totalIncome - totalExpense;

  CategoryBreakdownItem? get topCategory =>
      categoryBreakdown.isEmpty ? null : categoryBreakdown.first;

  factory ReportSummary.empty() => const ReportSummary(
      totalIncome: 0, totalExpense: 0, categoryBreakdown: [], trend: []);
}
