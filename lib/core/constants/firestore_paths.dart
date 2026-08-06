/// Nama koleksi Firestore terpusat — dipakai di seluruh data layer
/// agar tidak ada string koleksi yang ditulis manual berulang kali.
class FirestorePaths {
  FirestorePaths._();

  static const users = 'users';
  static const transactions = 'transactions';
  static const budgets = 'budgets';
}
