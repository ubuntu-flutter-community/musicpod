import 'dart:async';

import 'logging.dart';

class KeepAliveRegistry<I, T> {
  final _instances = <I, T>{};

  void register({
    required I id,
    required T instance,
    Duration? autoDisposeAfter,
  }) {
    printInfoInDebugMode('Instance created for id: $id', tag: '$T');
    _instances[id] = instance;
    if (autoDisposeAfter != null) {
      Future.delayed(
        autoDisposeAfter,
        () => dispose(
          id,
          message: 'Instance auto-disposed after $autoDisposeAfter',
        ),
      );
    }
  }

  T? get(I id) => _instances[id];

  T? dispose(I id, {String message = 'Instance disposed'}) {
    if (!_instances.containsKey(id)) return null;
    final instance = _instances.remove(id);
    if (instance != null) {
      printInfoInDebugMode('$message for id: $id', tag: '$T');
    }
    return instance;
  }
}
