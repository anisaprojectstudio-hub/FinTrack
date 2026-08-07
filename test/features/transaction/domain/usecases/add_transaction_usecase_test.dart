import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintrack/core/errors/failure.dart';
import 'package:fintrack/features/transaction/domain/entities/transaction_entity.dart';
import 'package:fintrack/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:fintrack/features/transaction/domain/usecases/add_transaction_usecase.dart';
import 'package:fintrack/shared/models/result.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

TransactionEntity _buildTransaction({double amount = 50000}) {
  return TransactionEntity(
    id: '',
    userId: 'u1',
    amount: amount,
    type: TransactionType.expense,
    category: 'Food',
    date: DateTime(2026, 8, 1),
  );
}

void main() {
  late MockTransactionRepository repository;
  late AddTransactionUseCase useCase;

  setUpAll(() {
    // Fallback wajib didaftarkan karena TransactionEntity adalah custom
    // class yang dipakai lewat any() di stubbing bawah.
    registerFallbackValue(_buildTransaction());
  });

  setUp(() {
    repository = MockTransactionRepository();
    useCase = AddTransactionUseCase(repository);
  });

  group('AddTransactionUseCase - validasi (tidak menyentuh repository)', () {
    test('menolak nominal 0 tanpa memanggil repository', () async {
      final result = await useCase(_buildTransaction(amount: 0));

      expect(result, isA<ResultFailure<void>>());
      verifyNever(() => repository.addTransaction(any()));
    });

    test('menolak nominal negatif tanpa memanggil repository', () async {
      final result = await useCase(_buildTransaction(amount: -1000));

      expect(result, isA<ResultFailure<void>>());
      verifyNever(() => repository.addTransaction(any()));
    });
  });

  group('AddTransactionUseCase - delegasi ke repository', () {
    test('meneruskan ke repository ketika nominal valid', () async {
      final transaction = _buildTransaction(amount: 50000);
      when(() => repository.addTransaction(any()))
          .thenAnswer((_) async => const Success(null));

      final result = await useCase(transaction);

      expect(result, isA<Success<void>>());
      verify(() => repository.addTransaction(transaction)).called(1);
    });

    test('meneruskan Failure dari repository apa adanya', () async {
      when(() => repository.addTransaction(any()))
          .thenAnswer((_) async => const ResultFailure(NetworkFailure()));

      final result = await useCase(_buildTransaction());

      expect(result, isA<ResultFailure<void>>());
    });
  });
}
