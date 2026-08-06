import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_label_formatter.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transaction_providers.dart';
import '../widgets/transaction_list_tile.dart';
import 'add_transaction_page.dart';

class TransactionListPage extends ConsumerStatefulWidget {
  const TransactionListPage({super.key});

  @override
  ConsumerState<TransactionListPage> createState() =>
      _TransactionListPageState();
}

class _TransactionListPageState extends ConsumerState<TransactionListPage> {
  TransactionType? _typeFilter; // null = semua

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddTransactionPage()),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _FilterBar(
            selectedMonth: selectedMonth,
            typeFilter: _typeFilter,
            onMonthChanged: (m) =>
                ref.read(selectedMonthProvider.notifier).setMonth(m),
            onTypeChanged: (t) => setState(() => _typeFilter = t),
          ),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final filtered = _typeFilter == null
                    ? transactions
                    : transactions.where((t) => t.type == _typeFilter).toList();

                if (filtered.isEmpty) {
                  return const Center(
                      child: Text('Belum ada transaksi di bulan ini.'));
                }
                return _GroupedList(transactions: filtered);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Gagal memuat transaksi: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final DateTime selectedMonth;
  final TransactionType? typeFilter;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<TransactionType?> onTypeChanged;

  const _FilterBar({
    required this.selectedMonth,
    required this.typeFilter,
    required this.onMonthChanged,
    required this.onTypeChanged,
  });

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onMonthChanged(
                DateTime(selectedMonth.year, selectedMonth.month - 1)),
          ),
          Text('${_months[selectedMonth.month - 1]} ${selectedMonth.year}',
              style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => onMonthChanged(
                DateTime(selectedMonth.year, selectedMonth.month + 1)),
          ),
          const Spacer(),
          DropdownButton<TransactionType?>(
            value: typeFilter,
            hint: const Text('Semua'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Semua')),
              DropdownMenuItem(
                  value: TransactionType.income, child: Text('Income')),
              DropdownMenuItem(
                  value: TransactionType.expense, child: Text('Expense')),
            ],
            onChanged: onTypeChanged,
          ),
        ],
      ),
    );
  }
}

/// Mengelompokkan transaksi per tanggal ("Hari Ini", "Kemarin", dst) —
/// data yang masuk sudah terurut terbaru dulu dari query Firestore (Tahap 3).
class _GroupedList extends StatelessWidget {
  final List<TransactionEntity> transactions;
  const _GroupedList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    String? lastLabel;

    for (final t in transactions) {
      final label = DateLabelFormatter.groupLabel(t.date);
      if (label != lastLabel) {
        items.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ));
        lastLabel = label;
      }
      items.add(_DismissibleTile(transaction: t));
    }

    return ListView(children: items);
  }
}

class _DismissibleTile extends ConsumerWidget {
  final TransactionEntity transaction;
  const _DismissibleTile({required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red.shade400,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hapus transaksi?'),
          content: Text('${transaction.category} — akan dihapus permanen.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Hapus')),
          ],
        ),
      ),
      onDismissed: (_) async {
        final controller =
            ref.read(deleteTransactionControllerProvider.notifier);
        await controller.delete(transaction.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Transaksi dihapus'),
              action: SnackBarAction(
                  label: 'Undo', onPressed: () => controller.undo(transaction)),
            ),
          );
        }
      },
      child: TransactionListTile(
        transaction: transaction,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => AddTransactionPage(existing: transaction)),
        ),
      ),
    );
  }
}
