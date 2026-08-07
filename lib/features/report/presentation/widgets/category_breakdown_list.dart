import 'package:flutter/material.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/report_summary.dart';

/// Tap satu kategori → drill-down ke Transaction List yang sudah
/// terfilter kategori itu (sesuai Tahap 4).
class CategoryBreakdownList extends StatelessWidget {
  final List<CategoryBreakdownItem> items;
  final ValueChanged<String> onCategoryTap;

  const CategoryBreakdownList(
      {super.key, required this.items, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text('Belum ada pengeluaran di periode ini.',
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return Column(
      children: items.map((item) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () => onCategoryTap(item.category),
          leading: Icon(AppCategories.iconFor(item.category)),
          title: Text(item.category),
          trailing: Text(
            '${item.percentage.toStringAsFixed(0)}% · ${CurrencyFormatter.format(item.total)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      }).toList(),
    );
  }
}
