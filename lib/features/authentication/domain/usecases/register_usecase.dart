import '../../../../shared/models/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);

  Future<Result<UserEntity>> call({
    required String name,
    required String email,
    required String password,
  }) {
    return repository.register(
        name: name.trim(), email: email.trim(), password: password);
  }
}
