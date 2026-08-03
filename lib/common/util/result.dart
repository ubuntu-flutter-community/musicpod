sealed class Result<S, E extends Exception> {}

final class Success<S, E extends Exception> extends Result<S, E> {
  final S value;
  Success(this.value);
}

final class Failure<S, E extends Exception> extends Result<S, E> {
  final E error;
  Failure(this.error);
}
