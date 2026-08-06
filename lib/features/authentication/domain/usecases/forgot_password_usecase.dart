import '../../../../shared/models/result.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;
  const ForgotPasswordUseCase(this.repository);

  Future<Result<void>> call(String email) =>
      repository.sendPasswordResetEmail(email.trim());
}
