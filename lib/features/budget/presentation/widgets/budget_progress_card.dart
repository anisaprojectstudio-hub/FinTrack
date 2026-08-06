import 'package:flutter/material.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/budget_progress.dart';

/// Warna berubah sesuai persentase pemakaian (sesuai Tahap 4):
/// hijau <70%, kuning 70–90%, merah >90%.
class BudgetProgressCard extends StatelessWidget {
  final BudgetProgress progress;
  final VoidCallback onTap;

  const BudgetProgressCard({super.key, required this.progress, required this.onTap});

  Color _colorFor(double percentage) {
    if (percentage > 90) return Colors.red.shade400;
    if (percentage >= 70) return Colors.amber.shade700;
    return Colors.green.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(progress.percentage);
    final clamped = progress.percentage.clamp(0, 100) / 100;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppCategories.iconFor(progress.budget.category), size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(progress.budget.category,
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                Text(
                  '${progress.percentage.toStringAsFixed(0)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: clamped.toDouble(),
                minHeight: 8,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${CurrencyFormatter.format(progress.spent)} dari ${CurrencyFormatter.format(progress.budget.limitAmount)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}