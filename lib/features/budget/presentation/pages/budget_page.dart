import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';
import '../providers/budget_providers.dart';
import '../widgets/budget_progress_card.dart';
import 'add_budget_page.dart';

class BudgetPage extends ConsumerWidget {
  const BudgetPage({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsStreamProvider);
    final progressList = ref.watch(budgetProgressListProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddBudgetPage()),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => ref
                      .read(selectedMonthProvider.notifier)
                      .setMonth(DateTime(
                          selectedMonth.year, selectedMonth.month - 1)),
                ),
                Text(
                    '${_months[selectedMonth.month - 1]} ${selectedMonth.year}',
                    style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => ref
                      .read(selectedMonthProvider.notifier)
                      .setMonth(DateTime(
                          selectedMonth.year, selectedMonth.month + 1)),
                ),
              ],
            ),
          ),
          Expanded(
            child: budgetsAsync.when(
              data: (_) {
                if (progressList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Belum ada budget bulan ini.\nTekan + untuk mulai atur budget per kategori.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: progressList.length,
                  itemBuilder: (context, index) {
                    final progress = progressList[index];
                    return BudgetProgressCard(
                      progress: progress,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                AddBudgetPage(existing: progress.budget)),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Gagal memuat budget: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
