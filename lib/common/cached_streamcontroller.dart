import 'dart:async';

class CachedStreamController<T> {
  T? _value;
  Object? _lastError;
  final StreamController<T> _streamController = StreamController.broadcast();

  CachedStreamController([T? value]) : _value = value;

  T? get value => _value;
  Object? get lastError => _lastError;
  Stream<T> get stream => _streamController.stream;

  void add(T value) {
    _value = value;
    _streamController.add(value);
  }

  void addError(Object error, [StackTrace? stackTrace]) {
    _lastError = value;
    _streamController.addError(error, stackTrace);
  }

  Future close() => _streamController.close();
  bool get isClosed => _streamController.isClosed;
}
