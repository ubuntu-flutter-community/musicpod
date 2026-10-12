import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'pause_timer_manager.g.dart';

@Riverpod(keepAlive: true)
class PauseTimerManager extends _$PauseTimerManager {
  PauseTimerManager({PlayerService? playerService})
      : _playerServiceOverride = playerService;

  final PlayerService? _playerServiceOverride;
  PlayerService? get _playerService {
    if (_playerServiceOverride != null) return _playerServiceOverride;
    if (di.isRegistered<PlayerService>()) return di<PlayerService>();
    return null;
  }

  StreamSubscription<PlayerChange>? _sub;

  @override
  bool build() {
    _sub?.cancel();
    final service = _playerService;
    if (service == null) return false;

    _sub = service.changes
        .whereType<TimerChange>()
        .listen((change) {
          state = change.isTimerActive;
        });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return service.timer != null;
  }

  Future<void> setTimer(Duration? duration, {required String message}) async {
    final service = _playerService;
    if (service == null) return;
    service.setPauseTimer(duration, message: message);
    state = service.timer != null;
  }
}
