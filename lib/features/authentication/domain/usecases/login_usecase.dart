import '../../../../shared/models/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Satu use case = satu aksi bisnis (sesuai Tahap 2), memudahkan testing
/// tanpa perlu widget atau Firebase.
class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  Future<Result<UserEntity>> call(
      {required String email, required String password}) {
    return repository.login(email: email.trim(), password: password);
  }
}
