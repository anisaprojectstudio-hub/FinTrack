import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../../core/errors/failure.dart';
import '../../../../shared/models/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implementasi nyata dari AuthRepository — mengubah exception Firebase
/// jadi Failure yang sudah diterjemahkan ke pesan ramah pengguna
/// (sesuai keputusan Tahap 1 & Tahap 2).
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  AuthRepositoryImpl(this._remote);

  @override
  Stream<UserEntity?> get authStateChanges => _remote.authStateChanges;

  @override
  Future<Result<UserEntity>> login(
      {required String email, required String password}) async {
    try {
      final user = await _remote.login(email: email, password: password);
      return Success(user);
    } on fb.FirebaseAuthException catch (e) {
      return ResultFailure(AuthFailure(_mapAuthError(e.code)));
    } catch (_) {
      return const ResultFailure(NetworkFailure());
    }
  }

  @override
  Future<Result<UserEntity>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user =
          await _remote.register(name: name, email: email, password: password);
      return Success(user);
    } on fb.FirebaseAuthException catch (e) {
      return ResultFailure(AuthFailure(_mapAuthError(e.code)));
    } catch (_) {
      return const ResultFailure(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remote.logout();
      return const Success(null);
    } catch (_) {
      return const ResultFailure(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _remote.sendPasswordResetEmail(email);
      return const Success(null);
    } on fb.FirebaseAuthException catch (e) {
      return ResultFailure(AuthFailure(_mapAuthError(e.code)));
    } catch (_) {
      return const ResultFailure(NetworkFailure());
    }
  }

  /// Terjemahan kode error Firebase → pesan Bahasa Indonesia yang jelas,
  /// bukan kode mentah seperti "[firebase_auth/invalid-credential]".
  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Coba login.';
      case 'weak-password':
        return 'Password terlalu lemah, gunakan minimal 6 karakter.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi beberapa saat lagi.';
      default:
        return 'Terjadi kesalahan. Coba lagi.';
    }
  }
}
