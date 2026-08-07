import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/update_name_usecase.dart';
import '../../domain/usecases/update_notification_setting_usecase.dart';
import '../../domain/usecases/upload_profile_photo_usecase.dart';
import '../../domain/usecases/watch_profile_usecase.dart';

// --- Dependency injection ---

final profileRemoteDataSourceProvider =
    Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource(firestore: FirebaseFirestore.instance);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider));
});

final watchProfileUseCaseProvider = Provider(
    (ref) => WatchProfileUseCase(ref.watch(profileRepositoryProvider)));
final updateNameUseCaseProvider =
    Provider((ref) => UpdateNameUseCase(ref.watch(profileRepositoryProvider)));
final uploadProfilePhotoUseCaseProvider = Provider(
    (ref) => UploadProfilePhotoUseCase(ref.watch(profileRepositoryProvider)));
final updateNotificationSettingUseCaseProvider = Provider((ref) =>
    UpdateNotificationSettingUseCase(ref.watch(profileRepositoryProvider)));

// --- Stream profil real-time (bereaksi ke perubahan nama/foto/notifikasi,
// beda dengan authStateProvider yang cuma berubah saat sign-in/sign-out) ---

final profileStreamProvider = StreamProvider<UserEntity>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(watchProfileUseCaseProvider).call(uid);
});

// --- Controller ubah nama ---

class ProfileFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> updateName(String uid, String name) async {
    state = const AsyncLoading();
    final result =
        await ref.read(updateNameUseCaseProvider).call(uid: uid, name: name);
    return result.when(
      success: (_) {
        state = const AsyncData(null);
        return true;
      },
      failure: (f) {
        state = AsyncError(f.message, StackTrace.current);
        return false;
      },
    );
  }
}

final profileFormControllerProvider =
    AsyncNotifierProvider<ProfileFormController, void>(
        ProfileFormController.new);

// --- Controller upload foto ---

class PhotoUploadController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> upload(File file) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    state = const AsyncLoading();
    final result = await ref
        .read(uploadProfilePhotoUseCaseProvider)
        .call(uid: uid, file: file);
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (f) => AsyncError(f.message, StackTrace.current),
    );
  }
}

final photoUploadControllerProvider =
    AsyncNotifierProvider<PhotoUploadController, void>(
        PhotoUploadController.new);

// --- Controller toggle notifikasi ---

class NotificationToggleController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> toggle(bool enabled) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    await ref
        .read(updateNotificationSettingUseCaseProvider)
        .call(uid: uid, enabled: enabled);
  }
}

final notificationToggleControllerProvider =
    AsyncNotifierProvider<NotificationToggleController, void>(
        NotificationToggleController.new);
