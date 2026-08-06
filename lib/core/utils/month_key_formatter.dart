/// Konversi DateTime → format "YYYY-MM" sesuai skema `budgets.month` (Tahap 3).
class MonthKeyFormatter {
  MonthKeyFormatter._();

  static String format(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }
}
