/// Representasi error di level domain — UI tidak pernah menerima
/// exception mentah dari Firebase, hanya Failure yang sudah diterjemahkan
/// jadi pesan yang ramah pengguna (sesuai keputusan Tahap 1 & Tahap 2).
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(
      [super.message = 'Tidak ada koneksi internet. Coba lagi.']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(
      [super.message = 'Terjadi kesalahan pada server. Coba lagi nanti.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
