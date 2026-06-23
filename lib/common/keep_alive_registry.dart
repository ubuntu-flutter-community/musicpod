import 'dart:async';

import 'logging.dart';

class KeepAliveRegistry<I, T> {
  final _instances = <I, T>{};

  T getOrRegister({
    required I id,
    required T Function() factoryFunction,
    Duration? autoDisposeAfter,
  }) {
    if (autoDisposeAfter != null) {
      Future.delayed(
        autoDisposeAfter,
        () => dispose(
          id,
          message: 'Instance auto-disposed after $autoDisposeAfter',
        ),
      );
    }
    return _instances.putIfAbsent(id, () {
      Logger.i('Instance created for id: $id', tag: '$T');
      return factoryFunction();
    });
  }

  T? dispose(I id, {String message = 'Instance disposed'}) {
    if (!_instances.containsKey(id)) return null;
    final instance = _instances.remove(id);
    if (instance != null) {
      Logger.i('$message for id: $id', tag: '$T');
    }
    return instance;
  }

  void disposeAll() {
    _instances.clear();
    Logger.i('All instances disposed', tag: '$T');
  }
}
