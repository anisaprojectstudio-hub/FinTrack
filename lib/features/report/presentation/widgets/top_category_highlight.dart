import 'package:flutter/material.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/report_summary.dart';

class TopCategoryHighlight extends StatelessWidget {
  final CategoryBreakdownItem item;

  const TopCategoryHighlight({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primary,
            child:
                Icon(AppCategories.iconFor(item.category), color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kategori Pengeluaran Terbesar',
                    style: Theme.of(context).textTheme.bodySmall),
                Text(
                  '${item.category} · ${CurrencyFormatter.format(item.total)}',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
