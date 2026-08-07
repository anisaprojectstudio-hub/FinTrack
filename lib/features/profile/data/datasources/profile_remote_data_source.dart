import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/utils/image_encoder.dart';
import '../../../authentication/data/models/user_model.dart';

/// Foto profil SENGAJA tidak pakai Firebase Storage — Storage kini wajib
/// paket berbayar (Blaze). Sebagai gantinya, foto dikompres kecil lalu
/// disimpan sebagai base64 langsung di field `photoUrl` pada dokumen
/// `users/{uid}` — tetap gratis di Firestore Spark plan selama ukuran
/// dokumen di bawah batas 1 MB (lihat core/utils/image_encoder.dart).
class ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProfileRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(FirestorePaths.users).doc(uid);

  Stream<UserModel> watchProfile(String uid) {
    return _userDoc(uid)
        .snapshots()
        .map((doc) => UserModel.fromJson(doc.data() ?? {}, uid));
  }

  Future<void> updateName({required String uid, required String name}) {
    return _userDoc(uid).update({'name': name});
  }

  /// Kompres foto ke base64 lalu simpan langsung ke field `photoUrl`.
  /// Throw [FormatException] kalau foto gagal dikompres/tetap kebesaran —
  /// ditangkap & diterjemahkan jadi Failure di repository layer.
  Future<void> uploadPhoto({required String uid, required File file}) async {
    final bytes = await file.readAsBytes();
    final dataUri = ImageEncoder.compressToDataUri(bytes);
    if (dataUri == null) {
      throw const FormatException('Foto terlalu besar atau tidak valid');
    }
    await _userDoc(uid).update({'photoUrl': dataUri});
  }

  Future<void> updateNotificationSetting(
      {required String uid, required bool enabled}) {
    return _userDoc(uid).update({'settings.notificationsEnabled': enabled});
  }
}
