import '../../../authentication/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class WatchProfileUseCase {
  final ProfileRepository repository;
  const WatchProfileUseCase(this.repository);

  Stream<UserEntity> call(String uid) => repository.watchProfile(uid);
}
