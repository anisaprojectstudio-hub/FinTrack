import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.type,
    required super.category,
    super.description,
    required super.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json, String id) {
    return TransactionModel(
      id: id,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.fromValue(json['type'] as String),
      category: json['category'] as String,
      description: json['description'] as String?,
      date: (json['date'] as Timestamp).toDate(),
    );
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      amount: entity.amount,
      type: entity.type,
      category: entity.category,
      description: entity.description,
      date: entity.date,
    );
  }

  /// [isUpdate] menentukan apakah field waktu yang ditulis `createdAt`
  /// (dokumen baru) atau `updatedAt` (dokumen yang diedit) — sesuai skema Tahap 3.
  Map<String, dynamic> toJson({bool isUpdate = false}) {
    return {
      'userId': userId,
      'amount': amount,
      'type': type.value,
      'category': category,
      'description': description,
      'date': Timestamp.fromDate(date),
      if (!isUpdate) 'createdAt': FieldValue.serverTimestamp(),
      if (isUpdate) 'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
