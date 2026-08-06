import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../models/user_model.dart';

/// Kelas yang benar-benar bicara ke Firebase Auth & Firestore.
/// Tidak ada logic bisnis di sini — murni komunikasi ke layanan eksternal
/// (sesuai batas tanggung jawab data layer di Tahap 2).
class AuthRemoteDataSource {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource({fb.FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _fetchUserModel(user.uid, fallbackEmail: user.email ?? '');
    });
  }

  Future<UserModel> login(
      {required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    final uid = credential.user!.uid;
    return _fetchUserModel(uid, fallbackEmail: email);
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final uid = credential.user!.uid;

    // Sesuai skema Tahap 3: dokumen profil dibuat begitu akun berhasil dibuat.
    final userDoc = {
      'name': name,
      'email': email,
      'photoUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
      'settings': {'currency': 'IDR', 'notificationsEnabled': true},
    };
    await _firestore.collection(FirestorePaths.users).doc(uid).set(userDoc);

    return UserModel(uid: uid, name: name, email: email, photoUrl: null);
  }

  Future<void> logout() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<UserModel> _fetchUserModel(String uid,
      {required String fallbackEmail}) async {
    final doc =
        await _firestore.collection(FirestorePaths.users).doc(uid).get();
    if (!doc.exists) {
      // Jaga-jaga: dokumen profil belum sempat terbuat (edge case jaringan).
      return UserModel(
          uid: uid, name: '', email: fallbackEmail, photoUrl: null);
    }
    return UserModel.fromJson(doc.data()!, uid);
  }
}
