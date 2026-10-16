import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'pause_timer_manager.g.dart';

@Riverpod(keepAlive: true)
class PauseTimerManager extends _$PauseTimerManager {
  PlayerService get _service => di<PlayerService>();

  StreamSubscription<PlayerChange>? _sub;

  @override
  bool build() {
    _sub?.cancel();

    _sub = _service.changes.whereType<TimerChange>().listen((change) {
      state = change.isTimerActive;
    });

    ref.onDispose(() => _sub?.cancel());

    return _service.timer != null;
  }

  Future<void> setTimer(Duration? duration, {required String message}) async {
    _service.setPauseTimer(duration, message: message);
    state = _service.timer != null;
  }
}
