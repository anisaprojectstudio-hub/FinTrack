import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:fintrack/core/utils/image_encoder.dart';

Uint8List _fakePngBytes(int width, int height) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(255, 0, 0));
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  group('ImageEncoder.compressToDataUri', () {
    test('menghasilkan data URI valid untuk gambar biasa', () {
      final result = ImageEncoder.compressToDataUri(_fakePngBytes(500, 500));

      expect(result, isNotNull);
      expect(result, startsWith('data:image/jpeg;base64,'));
    });

    test('mengecilkan dimensi ke maksimal 300px di sisi terpanjang', () {
      final dataUri = ImageEncoder.compressToDataUri(_fakePngBytes(2000, 1000));
      final decodedBytes = ImageEncoder.decodeDataUri(dataUri);
      final decodedImage = img.decodeImage(decodedBytes!);

      expect(decodedImage!.width, lessThanOrEqualTo(300));
      expect(decodedImage.height, lessThanOrEqualTo(300));
    });

    test('return null untuk bytes yang bukan gambar', () {
      final invalidBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      expect(ImageEncoder.compressToDataUri(invalidBytes), isNull);
    });
  });

  group('ImageEncoder.decodeDataUri', () {
    test('return null untuk input yang bukan data URI', () {
      expect(ImageEncoder.decodeDataUri(null), isNull);
      expect(ImageEncoder.decodeDataUri(''), isNull);
      expect(
          ImageEncoder.decodeDataUri('https://example.com/photo.jpg'), isNull);
    });

    test('berhasil membalikkan hasil compressToDataUri (round-trip)', () {
      final dataUri = ImageEncoder.compressToDataUri(_fakePngBytes(100, 100));
      final decoded = ImageEncoder.decodeDataUri(dataUri);

      expect(decoded, isNotNull);
      expect(img.decodeImage(decoded!), isNotNull);
    });
  });
}
