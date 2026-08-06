/// Entity murni domain — tidak tahu apa-apa tentang Firestore.
class BudgetEntity {
  final String id;
  final String userId;
  final String category;
  final double limitAmount;
  final String month; // format "YYYY-MM", sesuai skema Tahap 3

  const BudgetEntity({
    required this.id,
    required this.userId,
    required this.category,
    required this.limitAmount,
    required this.month,
  });
}
