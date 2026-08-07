import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';

class ReportSummaryRow extends StatelessWidget {
  final double income;
  final double expense;
  final double net;

  const ReportSummaryRow(
      {super.key,
      required this.income,
      required this.expense,
      required this.net});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _StatTile(
                label: 'Pemasukan',
                amount: income,
                color: Colors.green.shade600)),
        const SizedBox(width: 8),
        Expanded(
            child: _StatTile(
                label: 'Pengeluaran',
                amount: expense,
                color: Colors.red.shade400)),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            label: 'Selisih',
            amount: net,
            color: net >= 0 ? Colors.green.shade600 : Colors.red.shade400,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _StatTile(
      {required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(amount),
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
