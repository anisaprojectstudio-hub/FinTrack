import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintrack/features/budget/domain/entities/budget_entity.dart';
import 'package:fintrack/features/budget/domain/repositories/budget_repository.dart';
import 'package:fintrack/features/budget/domain/usecases/add_budget_usecase.dart';
import 'package:fintrack/shared/models/result.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  late MockBudgetRepository repository;
  late AddBudgetUseCase useCase;

  const budget = BudgetEntity(
      id: '',
      userId: 'u1',
      category: 'Food',
      limitAmount: 500000,
      month: '2026-08');

  setUpAll(() {
    registerFallbackValue(budget);
  });

  setUp(() {
    repository = MockBudgetRepository();
    useCase = AddBudgetUseCase(repository);
  });

  test('menolak limit 0 tanpa memanggil repository', () async {
    const zeroBudget = BudgetEntity(
        id: '',
        userId: 'u1',
        category: 'Food',
        limitAmount: 0,
        month: '2026-08');

    final result =
        await useCase(zeroBudget, existingBudgetsThisMonth: const []);

    expect(result, isA<ResultFailure<void>>());
    verifyNever(() => repository.addBudget(any()));
  });

  test('menolak kategori yang sudah punya budget bulan ini (anti-duplikasi)',
      () async {
    final result =
        await useCase(budget, existingBudgetsThisMonth: const [budget]);

    expect(result, isA<ResultFailure<void>>());
    verifyNever(() => repository.addBudget(any()));
  });

  test(
      'kategori yang sama tapi BUKAN duplikat kalau tidak ada di existingBudgetsThisMonth',
      () async {
    when(() => repository.addBudget(any()))
        .thenAnswer((_) async => const Success(null));

    final result = await useCase(budget, existingBudgetsThisMonth: const []);

    expect(result, isA<Success<void>>());
  });

  test('meneruskan ke repository kalau valid dan kategori belum ada budget',
      () async {
    when(() => repository.addBudget(any()))
        .thenAnswer((_) async => const Success(null));

    final result = await useCase(budget, existingBudgetsThisMonth: const []);

    expect(result, isA<Success<void>>());
    verify(() => repository.addBudget(budget)).called(1);
  });
}
