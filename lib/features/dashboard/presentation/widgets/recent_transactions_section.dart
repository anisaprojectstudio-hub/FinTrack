import 'package:flutter/material.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/presentation/widgets/transaction_list_tile.dart';

/// Section "Transaksi Terakhir" di Dashboard (sesuai Tahap 4) — menampilkan
/// beberapa item teratas dan link ke Transaction List lengkap.
class RecentTransactionsSection extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final VoidCallback onSeeAll;
  final int maxItems;

  const RecentTransactionsSection({
    super.key,
    required this.transactions,
    required this.onSeeAll,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final items = transactions.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Transaksi Terakhir',
                style: Theme.of(context).textTheme.titleMedium),
            TextButton(onPressed: onSeeAll, child: const Text('Lihat Semua')),
          ],
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Belum ada transaksi — yuk catat yang pertama!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          ...items.map((t) => TransactionListTile(transaction: t)),
      ],
    );
  }
}
