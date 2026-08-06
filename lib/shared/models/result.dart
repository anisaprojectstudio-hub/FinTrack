import '../../core/errors/failure.dart';

/// Wrapper hasil operasi: sukses membawa data [T], gagal membawa [Failure].
/// Dipakai di semua repository agar UI tidak perlu try-catch exception
/// mentah — cukup pattern match Success/ResultFailure lewat [when].
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    if (self is ResultFailure<T>) return failure(self.failure);
    throw StateError('Unknown Result subtype');
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class ResultFailure<T> extends Result<T> {
  final Failure failure;
  const ResultFailure(this.failure);
}
