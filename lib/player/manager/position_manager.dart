import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'position_manager.g.dart';

@Riverpod(keepAlive: true)
class PositionManager extends _$PositionManager {
  PositionManager({PlayerService? playerService})
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

    _sub = service.changes
        .whereType<PositionChange>()
        .listen((change) {
          state = change.position;
        });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return service.position;
  }

  Future<void> seek(Duration position) async {
    final service = _playerService;
    if (service == null) return;
    await service.seek(position);
  }

  Future<void> seekInSeconds(int seconds) async {
    final current = state;
    if (current != null && current.inSeconds + seconds >= 0) {
      await seek(Duration(seconds: current.inSeconds + seconds));
    }
  }
}
