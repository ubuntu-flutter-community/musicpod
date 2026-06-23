import 'dart:async';

import 'logging.dart';

class KeepAliveRegistry<I, T> {
  final _instances = <I, T>{};

  KeepAliveRegistry({Duration autoDisposeAllAfter = const Duration(hours: 1)}) {
    Future.delayed(autoDisposeAllAfter, () => disposeAll());
  }

  T getOrRegister({
    required I id,
    required T Function() factoryFunction,
    Duration autoDisposeAfter = const Duration(minutes: 5),
  }) {
    Future.delayed(
      autoDisposeAfter,
      () => dispose(id, reason: 'Auto dispose after $autoDisposeAfter'),
    );

    return _instances.putIfAbsent(id, () {
      Logger.i('Instance created for id: $id', tag: '$T');
      return factoryFunction();
    });
  }

  T? dispose(I id, {String? reason}) {
    final message =
        '${reason != null ? '$reason. ' : ''}Instance reference for id: $id removed, will be garbage collected if no other references exist';
    if (!_instances.containsKey(id)) return null;
    final instance = _instances.remove(id);
    if (instance != null) {
      Logger.i('$message for id: $id', tag: '$T');
    }
    return instance;
  }

  void disposeAll({String? reason}) {
    _instances.clear();

    Logger.i(
      '${reason != null ? '$reason. ' : ''}All instances of $T disposed',
      tag: '$T',
    );
  }
}
