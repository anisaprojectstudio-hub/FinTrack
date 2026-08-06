import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Kartu paling menonjol di Dashboard (sesuai Tahap 4) — menampilkan
/// Total Saldo keseluruhan (bukan cuma bulan berjalan).
class BalanceCard extends StatelessWidget {
  final double balance;

  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Saldo',
            style: TextStyle(
                color: colorScheme.onPrimary.withOpacity(0.8), fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(balance),
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
