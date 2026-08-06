/// Validator form — dipakai di semua fitur yang butuh validasi (Auth, dst),
/// dipusatkan di sini agar aturan validasi konsisten di seluruh app.
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!regex.hasMatch(value.trim())) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty)
      return 'Konfirmasi password wajib diisi';
    if (value != original) return 'Konfirmasi password tidak sama';
    return null;
  }
}
