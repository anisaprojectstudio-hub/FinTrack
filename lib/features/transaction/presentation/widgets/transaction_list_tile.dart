import 'package:flutter/material.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionListTile extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback? onTap;

  const TransactionListTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green.shade600 : Colors.red.shade400;
    final sign = isIncome ? '+' : '-';

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.12),
        child: Icon(AppCategories.iconFor(transaction.category), color: color),
      ),
      title: Text(transaction.category),
      subtitle: (transaction.description != null &&
              transaction.description!.isNotEmpty)
          ? Text(transaction.description!)
          : null,
      trailing: Text(
        '$sign${CurrencyFormatter.format(transaction.amount)}',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
