import '../../../../shared/models/result.dart';
import '../repositories/profile_repository.dart';

class UpdateNotificationSettingUseCase {
  final ProfileRepository repository;
  const UpdateNotificationSettingUseCase(this.repository);

  Future<Result<void>> call({required String uid, required bool enabled}) {
    return repository.updateNotificationSetting(uid: uid, enabled: enabled);
  }
}
