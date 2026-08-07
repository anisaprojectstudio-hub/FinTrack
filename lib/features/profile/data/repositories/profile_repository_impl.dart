import 'dart:io';
import '../../../../core/errors/failure.dart';
import '../../../../shared/models/result.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;
  ProfileRepositoryImpl(this._remote);

  @override
  Stream<UserEntity> watchProfile(String uid) => _remote.watchProfile(uid);

  @override
  Future<Result<void>> updateName(
      {required String uid, required String name}) async {
    try {
      await _remote.updateName(uid: uid, name: name);
      return const Success(null);
    } catch (_) {
      return const ResultFailure(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> uploadPhoto(
      {required String uid, required File file}) async {
    try {
      await _remote.uploadPhoto(uid: uid, file: file);
      return const Success(null);
    } on FormatException catch (e) {
      return ResultFailure(ValidationFailure(e.message));
    } catch (_) {
      return const ResultFailure(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> updateNotificationSetting(
      {required String uid, required bool enabled}) async {
    try {
      await _remote.updateNotificationSetting(uid: uid, enabled: enabled);
      return const Success(null);
    } catch (_) {
      return const ResultFailure(NetworkFailure());
    }
  }
}
