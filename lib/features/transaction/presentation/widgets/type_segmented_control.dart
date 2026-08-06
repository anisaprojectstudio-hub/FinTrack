import 'package:flutter/material.dart';
import '../../domain/entities/transaction_entity.dart';

class TypeSegmentedControl extends StatelessWidget {
  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  const TypeSegmentedControl(
      {super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TransactionType>(
      segments: const [
        ButtonSegment(
            value: TransactionType.expense, label: Text('Pengeluaran')),
        ButtonSegment(value: TransactionType.income, label: Text('Pemasukan')),
      ],
      selected: {value},
      onSelectionChanged: (set) => onChanged(set.first),
    );
  }
}
