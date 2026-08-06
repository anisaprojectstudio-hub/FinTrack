import 'package:flutter/material.dart';
import '../../../../core/constants/categories.dart';
import '../../domain/entities/transaction_entity.dart';

class CategoryGridPicker extends StatelessWidget {
  final TransactionType type;
  final String? selected;
  final ValueChanged<String> onSelected;

  const CategoryGridPicker({
    super.key,
    required this.type,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = type == TransactionType.income
        ? AppCategories.income
        : AppCategories.expense;
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = category == selected;
        return InkWell(
          onTap: () => onSelected(category),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceVariant,
                child: Icon(
                  AppCategories.iconFor(category),
                  color:
                      isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(category,
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }
}
