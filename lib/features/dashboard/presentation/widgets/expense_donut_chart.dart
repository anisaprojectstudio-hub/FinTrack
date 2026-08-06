import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/dashboard_summary.dart';

/// Grafik donut pengeluaran per kategori bulan berjalan (sesuai Tahap 4) —
/// sengaja dibuat sederhana (bukan padat data) supaya insight utama
/// ("kategori mana yang paling boros") langsung terlihat.
class ExpenseDonutChart extends StatelessWidget {
  final List<CategoryExpense> data;

  const ExpenseDonutChart({super.key, required this.data});

  static const _palette = [
    Color(0xFF0F5132),
    Color(0xFF2E7D32),
    Color(0xFF66BB6A),
    Color(0xFFAED581),
    Color(0xFFFFB74D),
    Color(0xFFE57373),
    Color(0xFF9575CD),
    Color(0xFF4FC3F7),
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text('Belum ada pengeluaran bulan ini',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }

    return Row(
      children: [
        SizedBox(
          height: 140,
          width: 140,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              sections: [
                for (var i = 0; i < data.length; i++)
                  PieChartSectionData(
                    value: data[i].total,
                    color: _palette[i % _palette.length],
                    radius: 24,
                    showTitle: false,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tampilkan maksimal 4 kategori teratas agar legend tetap ringkas.
              for (var i = 0; i < data.length && i < 4; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _palette[i % _palette.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(AppCategories.iconFor(data[i].category), size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${data[i].category} · ${data[i].percentage.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (data.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Terbesar: ${data.first.category} (${CurrencyFormatter.format(data.first.total)})',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
