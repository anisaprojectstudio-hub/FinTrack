import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Encoder foto profil TANPA Firebase Storage — Storage kini wajib paket
/// berbayar (Blaze), jadi foto dikompres kecil lalu disimpan sebagai
/// base64 langsung di field `photoUrl` pada dokumen `users/{uid}` di
/// Firestore. Firestore (Spark/free plan) tidak kena biaya tambahan untuk
/// ini selama ukuran dokumen tetap di bawah batas 1 MB — foto profil kecil
/// jauh di bawah itu.
class ImageEncoder {
  ImageEncoder._();

  /// Batas aman base64 per foto — menyisakan ruang untuk field lain
  /// (name, email, settings) di dokumen yang sama.
  static const _maxBase64Chars = 700 * 1024;

  /// Mengecilkan gambar ke maksimal 300px di sisi terpanjang, lalu
  /// menurunkan kualitas JPEG bertahap sampai muat di batas aman.
  /// Return null kalau gambar gagal didekode atau tetap kebesaran.
  static String? compressToDataUri(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    final isLandscape = decoded.width >= decoded.height;
    final resized = img.copyResize(
      decoded,
      width: isLandscape ? 300 : null,
      height: isLandscape ? null : 300,
    );

    for (final quality in [70, 50, 35, 20]) {
      final jpg = img.encodeJpg(resized, quality: quality);
      final base64Str = base64Encode(jpg);
      if (base64Str.length <= _maxBase64Chars) {
        return 'data:image/jpeg;base64,$base64Str';
      }
    }
    return null; // tetap kebesaran walau sudah dikompres maksimal
  }

  /// Kebalikan dari [compressToDataUri] — dipakai widget untuk menampilkan
  /// foto lewat Image.memory(). Return null kalau bukan data URI valid
  /// (misal masih kosong / null / format lama).
  static Uint8List? decodeDataUri(String? dataUri) {
    if (dataUri == null || !dataUri.startsWith('data:image')) return null;
    final commaIndex = dataUri.indexOf(',');
    if (commaIndex == -1) return null;
    try {
      return base64Decode(dataUri.substring(commaIndex + 1));
    } catch (_) {
      return null;
    }
  }
}
