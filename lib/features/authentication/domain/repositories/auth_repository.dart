import '../../../../shared/models/result.dart';
import '../entities/user_entity.dart';

/// Kontrak autentikasi — domain tidak tahu implementasinya pakai
/// Firebase Auth atau bukan (sesuai Dependency Rule Tahap 2).
abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;

  Future<Result<UserEntity>> login(
      {required String email, required String password});

  Future<Result<UserEntity>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Result<void>> logout();

  Future<Result<void>> sendPasswordResetEmail(String email);
}
