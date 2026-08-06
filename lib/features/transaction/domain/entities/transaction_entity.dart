enum TransactionType {
  income,
  expense;

  String get value => name; // 'income' | 'expense' — sesuai skema Tahap 3

  static TransactionType fromValue(String value) {
    return TransactionType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => TransactionType.expense,
    );
  }
}

/// Entity murni domain — tidak tahu apa-apa tentang Firestore.
class TransactionEntity {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final String category;
  final String? description;
  final DateTime date;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    this.description,
    required this.date,
  });
}
