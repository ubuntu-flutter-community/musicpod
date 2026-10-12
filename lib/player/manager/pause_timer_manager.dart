import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
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

  StreamSubscription<bool>? _sub;

  @override
  bool build() {
    _sub?.cancel();
    final service = _playerService;
    if (service == null) return false;

    _sub = service.propertiesChanged.listen((_) {
      final isTimerActive = service.timer != null;
      if (state != isTimerActive) {
        state = isTimerActive;
      }
    });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return service.timer != null;
  }

  void setTimer(Duration? duration, {required String message}) {
    final service = _playerService;
    if (service != null) {
      service.setPauseTimer(duration, message: message);
      state = service.timer != null;
    } else {
      state = false;
    }
  }
}
