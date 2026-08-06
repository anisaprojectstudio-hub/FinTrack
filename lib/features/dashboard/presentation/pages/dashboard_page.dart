import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../transaction/presentation/pages/add_transaction_page.dart';
import '../../../transaction/presentation/pages/transaction_list_page.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/balance_card.dart';
import '../widgets/expense_donut_chart.dart';
import '../widgets/recent_transactions_section.dart';
import '../widgets/summary_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final isLoading = ref.watch(dashboardLoadingProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final recentTransactions =
        ref.watch(allTransactionsStreamProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Halo, ${(user?.name.isNotEmpty ?? false) ? user!.name : 'FinTrack'} 👋'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddTransactionPage()),
        ),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // Data sudah real-time lewat StreamProvider — refresh manual di
              // sini murni untuk kenyamanan UX (menegaskan "data sudah terbaru").
              onRefresh: () async =>
                  Future.delayed(const Duration(milliseconds: 400)),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  BalanceCard(balance: summary.totalBalance),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          label: 'Pemasukan Bulan Ini',
                          amount: summary.monthIncome,
                          icon: Icons.arrow_downward,
                          color: Colors.green.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          label: 'Pengeluaran Bulan Ini',
                          amount: summary.monthExpense,
                          icon: Icons.arrow_upward,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Pengeluaran per Kategori',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ExpenseDonutChart(data: summary.expenseByCategory),
                  const SizedBox(height: 24),
                  RecentTransactionsSection(
                    transactions: recentTransactions,
                    onSeeAll: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const TransactionListPage()),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
