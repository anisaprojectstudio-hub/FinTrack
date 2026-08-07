import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('menolak email kosong', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('menolak format email tidak valid', () {
      expect(Validators.email('bukan-email'), isNotNull);
      expect(Validators.email('bukan@email'), isNotNull);
    });

    test('menerima email valid', () {
      expect(Validators.email('user@example.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('menolak password kosong', () {
      expect(Validators.password(''), isNotNull);
    });

    test('menolak password kurang dari 6 karakter', () {
      expect(Validators.password('12345'), isNotNull);
    });

    test('menerima password 6 karakter atau lebih', () {
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('menolak kalau tidak sama dengan original', () {
      expect(Validators.confirmPassword('abc123', 'abc124'), isNotNull);
    });

    test('menolak kalau kosong', () {
      expect(Validators.confirmPassword('', 'abc123'), isNotNull);
    });

    test('menerima kalau sama persis', () {
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
    });
  });
}
