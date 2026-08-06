import 'package:intl/intl.dart';

/// Formatter Rupiah terpusat — dipakai di semua tempat yang menampilkan
/// nominal (list transaksi, dashboard, report) agar formatnya konsisten.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  static String format(num amount) => _formatter.format(amount);
}
