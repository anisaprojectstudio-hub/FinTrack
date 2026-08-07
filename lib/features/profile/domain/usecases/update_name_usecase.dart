import '../../../../core/errors/failure.dart';
import '../../../../shared/models/result.dart';
import '../repositories/profile_repository.dart';

class UpdateNameUseCase {
  final ProfileRepository repository;
  const UpdateNameUseCase(this.repository);

  Future<Result<void>> call({required String uid, required String name}) {
    if (name.trim().isEmpty) {
      return Future.value(
          const ResultFailure(ValidationFailure('Nama tidak boleh kosong')));
    }
    return repository.updateName(uid: uid, name: name.trim());
  }
}
