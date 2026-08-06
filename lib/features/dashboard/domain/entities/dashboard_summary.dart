/// Total pengeluaran satu kategori beserta persentasenya terhadap total
/// pengeluaran bulan berjalan — dasar untuk grafik donut Dashboard.
class CategoryExpense {
  final String category;
  final double total;
  final double percentage; // 0–100

  const CategoryExpense(
      {required this.category, required this.total, required this.percentage});
}

/// Ringkasan yang ditampilkan di Dashboard — dihitung murni dari data
/// transaksi yang sudah ada (Dashboard tidak punya data layer sendiri,
/// sesuai keputusan Tahap 2).
class DashboardSummary {
  final double totalBalance;
  final double monthIncome;
  final double monthExpense;
  final List<CategoryExpense> expenseByCategory;

  const DashboardSummary({
    required this.totalBalance,
    required this.monthIncome,
    required this.monthExpense,
    required this.expenseByCategory,
  });

  factory DashboardSummary.empty() => const DashboardSummary(
        totalBalance: 0,
        monthIncome: 0,
        monthExpense: 0,
        expenseByCategory: [],
      );
}
