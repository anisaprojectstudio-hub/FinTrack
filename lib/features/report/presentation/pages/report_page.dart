import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transaction/presentation/pages/transaction_list_page.dart';
import '../providers/report_providers.dart';
import '../widgets/category_breakdown_list.dart';
import '../widgets/period_toggle.dart';
import '../widgets/report_summary_row.dart';
import '../widgets/report_trend_chart.dart';
import '../widgets/top_category_highlight.dart';

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    final summary = ref.watch(reportSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PeriodToggle(
            value: period,
            onChanged: (p) => ref.read(reportPeriodProvider.notifier).state = p,
          ),
          const SizedBox(height: 16),
          ReportSummaryRow(
              income: summary.totalIncome,
              expense: summary.totalExpense,
              net: summary.net),
          const SizedBox(height: 24),
          Text('Tren Pengeluaran',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ReportTrendChart(points: summary.trend),
          const SizedBox(height: 20),
          if (summary.topCategory != null) ...[
            TopCategoryHighlight(item: summary.topCategory!),
            const SizedBox(height: 20),
          ],
          Text('Rincian per Kategori',
              style: Theme.of(context).textTheme.titleMedium),
          CategoryBreakdownList(
            items: summary.categoryBreakdown,
            onCategoryTap: (category) => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) =>
                      TransactionListPage(initialCategory: category)),
            ),
          ),
        ],
      ),
    );
  }
}
