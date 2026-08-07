import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/report_summary.dart';

/// Grafik batang sederhana — mingguan per hari (7 batang), bulanan per
/// minggu-ke (maks 5 batang), sengaja tidak per-hari penuh supaya tidak
/// padat data (sesuai prinsip UX Tahap 4).
class ReportTrendChart extends StatelessWidget {
  final List<TrendPoint> points;

  const ReportTrendChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty || points.every((p) => p.expense == 0)) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text('Belum ada pengeluaran di periode ini',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }

    final maxY =
        points.map((p) => p.expense).reduce((a, b) => a > b ? a : b) * 1.2;
    final color = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxY == 0 ? 1 : maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length)
                    return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(points[index].label,
                        style: Theme.of(context).textTheme.labelSmall),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: points[i].expense,
                    color: color,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
