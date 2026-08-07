import 'package:flutter/material.dart';
import '../../domain/entities/report_period.dart';

class PeriodToggle extends StatelessWidget {
  final ReportPeriod value;
  final ValueChanged<ReportPeriod> onChanged;

  const PeriodToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ReportPeriod>(
      segments: const [
        ButtonSegment(value: ReportPeriod.weekly, label: Text('Mingguan')),
        ButtonSegment(value: ReportPeriod.monthly, label: Text('Bulanan')),
      ],
      selected: {value},
      onSelectionChanged: (set) => onChanged(set.first),
    );
  }
}
