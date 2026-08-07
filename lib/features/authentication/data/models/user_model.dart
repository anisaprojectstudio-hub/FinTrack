import '../../domain/entities/user_entity.dart';

/// Representasi data mentah dari Firestore — punya fromJson/toJson,
/// diubah jadi UserEntity murni sebelum masuk ke domain/presentation
/// (sesuai pemisahan layer di Tahap 2).
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    super.photoUrl,
    super.notificationsEnabled,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String uid) {
    final settings = json['settings'] as Map<String, dynamic>?;
    return UserModel(
      uid: uid,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      notificationsEnabled: settings?['notificationsEnabled'] as bool? ?? true,
    );
  }
}
