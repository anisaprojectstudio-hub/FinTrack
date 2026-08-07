import 'dart:io';
import '../../../../shared/models/result.dart';
import '../repositories/profile_repository.dart';

class UploadProfilePhotoUseCase {
  final ProfileRepository repository;
  const UploadProfilePhotoUseCase(this.repository);

  Future<Result<void>> call({required String uid, required File file}) {
    return repository.uploadPhoto(uid: uid, file: file);
  }
}
