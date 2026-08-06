import 'package:flutter/material.dart';

/// Kategori default (sesuai Tahap 1) — MVP belum mendukung kategori
/// kustom per user, jadi disimpan sebagai konstanta statis di client.
class AppCategories {
  AppCategories._();

  static const income = <String>['Salary', 'Business', 'Gift', 'Other'];

  static const expense = <String>[
    'Food',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills',
    'Education',
    'Health',
    'Other',
  ];

  /// Ikon per kategori — dipakai konsisten di list transaksi & form tambah.
  static const Map<String, IconData> _icons = {
    'Salary': Icons.payments_outlined,
    'Business': Icons.storefront_outlined,
    'Gift': Icons.card_giftcard_outlined,
    'Food': Icons.restaurant_outlined,
    'Transportation': Icons.directions_bus_outlined,
    'Shopping': Icons.shopping_bag_outlined,
    'Entertainment': Icons.movie_outlined,
    'Bills': Icons.receipt_long_outlined,
    'Education': Icons.school_outlined,
    'Health': Icons.favorite_outline,
    'Other': Icons.more_horiz,
  };

  static IconData iconFor(String category) =>
      _icons[category] ?? Icons.more_horiz;
}
