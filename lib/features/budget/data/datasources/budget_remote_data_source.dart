import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../models/budget_model.dart';

class BudgetRemoteDataSource {
  final FirebaseFirestore _firestore;
  BudgetRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirestorePaths.budgets);

  /// Query sesuai pola Tahap 3 — butuh composite index (userId + month).
  Stream<List<BudgetModel>> watchBudgets(
      {required String userId, required String month}) {
    return _col
        .where('userId', isEqualTo: userId)
        .where('month', isEqualTo: month)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => BudgetModel.fromJson(d.data(), d.id))
            .toList());
  }

  Future<void> addBudget(BudgetModel budget) {
    return _col.add({
      'userId': budget.userId,
      'category': budget.category,
      'limitAmount': budget.limitAmount,
      'month': budget.month,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Hanya field yang boleh berubah (category tetap terkunci dari UI saat
  /// edit) — createdAt sengaja tidak disentuh lagi.
  Future<void> updateBudget(BudgetModel budget) {
    return _col.doc(budget.id).update({'limitAmount': budget.limitAmount});
  }

  Future<void> deleteBudget(String id) {
    return _col.doc(id).delete();
  }
}
