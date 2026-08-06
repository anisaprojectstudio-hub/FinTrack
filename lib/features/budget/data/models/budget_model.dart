import '../../domain/entities/budget_entity.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.userId,
    required super.category,
    required super.limitAmount,
    required super.month,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json, String id) {
    return BudgetModel(
      id: id,
      userId: json['userId'] as String,
      category: json['category'] as String,
      limitAmount: (json['limitAmount'] as num).toDouble(),
      month: json['month'] as String,
    );
  }

  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      userId: entity.userId,
      category: entity.category,
      limitAmount: entity.limitAmount,
      month: entity.month,
    );
  }
}
