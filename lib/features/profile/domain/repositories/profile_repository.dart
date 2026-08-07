import 'dart:io';
import '../../../../shared/models/result.dart';
import '../../../authentication/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  /// Real-time data profil — dipakai supaya perubahan nama/foto/notifikasi
  /// langsung tercermin di UI tanpa perlu logout-login (beda dengan
  /// authStateChanges yang hanya berubah saat sign-in/sign-out).
  Stream<UserEntity> watchProfile(String uid);

  Future<Result<void>> updateName({required String uid, required String name});

  Future<Result<void>> uploadPhoto({required String uid, required File file});

  Future<Result<void>> updateNotificationSetting(
      {required String uid, required bool enabled});
}
