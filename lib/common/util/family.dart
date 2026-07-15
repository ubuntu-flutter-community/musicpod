import 'dart:async';

import '../logging.dart';

/// A single, process-wide registry that keeps one instance alive per
/// `(type, id)` combination.
///
/// Each class decides its own lifetime by passing
/// [shouldDispose] (and optionally [onDispose]) at the call site, so `Family`
/// stays agnostic of whether the instance uses commands, listeners, timers, …
///
/// Typical usage from an `injectable` `@factoryMethod`:
///
/// ```dart
/// @factoryMethod
/// static MyManager create({@factoryParam required String id, ...}) => Family.of(
///       id,
///       () => MyManager._(...),
///       shouldDispose: (m) => m.command.listenerCount == 0,
///       onDispose: (m) => m.command.dispose(),
///     );
/// ```
abstract final class Family {
  Family._();

  static final _entries = <(Type, Object?), _FamilyEntry>{};

  /// Returns the cached instance for `([T], [id])` or creates, caches and
  /// returns a new one.
  ///
  /// After [autoDisposeAfter] the instance is checked via [shouldDispose]:
  /// while it returns `false` the instance is kept alive and re-checked; once
  /// it returns `true` the instance is removed and [onDispose] is called.
  static T of<T extends Object>(
    Object? id,
    T Function() create, {
    required bool Function(T instance) shouldDispose,
    FutureOr<void> Function(T instance)? onDispose,
    Duration autoDisposeAfter = const Duration(seconds: 5),
  }) {
    final key = (T, id);
    final existing = _entries[key];
    if (existing != null) return existing.instance as T;

    final instance = create();
    _entries[key] = _FamilyEntry(
      instance: instance,
      canDispose: () => shouldDispose(instance),
      onDisposeInstance: () => onDispose?.call(instance),
    );
    Logger.o(tag: '$T:$id');
    _scheduleDispose(key, autoDisposeAfter);
    return instance;
  }

  static void _scheduleDispose((Type, Object?) key, Duration after) {
    Future.delayed(after, () {
      final entry = _entries[key];
      if (entry == null) return;
      if (!entry.canDispose()) {
        // Logger.o(tag: '${key.$1}:${key.$2}', message: 'kept alive!');
        _scheduleDispose(key, after);
        return;
      }
      _entries.remove(key);
      entry.onDisposeInstance();
      Logger.o(tag: '${key.$1}:${key.$2}', message: 'removed!');
    });
  }

  /// Removes and disposes the instance for `([T], [id])` if present and returns
  /// it, or `null` when nothing was registered.
  static T? dispose<T extends Object>(Object? id) {
    final entry = _entries.remove((T, id));
    if (entry == null) return null;
    entry.onDisposeInstance();
    return entry.instance as T;
  }

  /// Removes and disposes every registered instance of type [T], regardless of
  /// its id.
  static void disposeAll<T extends Object>() {
    final keys = _entries.keys.where((key) => key.$1 == T).toList();
    for (final key in keys) {
      _entries.remove(key)?.onDisposeInstance();
    }
  }

  /// Disposes and clears every registered instance. Mainly useful in tests.
  static Future<void> reset() async {
    final entries = _entries.values.toList();
    _entries.clear();
    for (final entry in entries) {
      await entry.onDisposeInstance();
    }
  }
}

class _FamilyEntry {
  _FamilyEntry({
    required this.instance,
    required this.canDispose,
    required this.onDisposeInstance,
  });

  final Object instance;
  final bool Function() canDispose;
  final FutureOr<void> Function() onDisposeInstance;
}
