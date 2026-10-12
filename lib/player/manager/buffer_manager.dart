import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'buffer_manager.g.dart';

@Riverpod(keepAlive: true)
class BufferManager extends _$BufferManager {
  BufferManager({PlayerService? playerService})
    : _playerServiceOverride = playerService;

  final PlayerService? _playerServiceOverride;
  PlayerService? get _playerService {
    if (_playerServiceOverride != null) return _playerServiceOverride;
    if (di.isRegistered<PlayerService>()) return di<PlayerService>();
    return null;
  }

  StreamSubscription<PlayerChange>? _sub;

  @override
  Duration? build() {
    _sub?.cancel();
    final service = _playerService;
    if (service == null) return Duration.zero;

    _sub = service.changes.whereType<BufferChange>().listen((change) {
      state = change.buffer;
    });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return service.buffer;
  }
}
