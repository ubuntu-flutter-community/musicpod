import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'position_manager.g.dart';

@Riverpod(keepAlive: true)
class PositionManager extends _$PositionManager {
  PlayerService get _service => di<PlayerService>();

  StreamSubscription<PlayerChange>? _sub;

  @override
  Duration? build() {
    _sub?.cancel();

    _sub = _service.changes.whereType<PositionChange>().listen((change) {
      state = change.position;
    });

    ref.onDispose(() => _sub?.cancel());

    return _service.position;
  }

  Future<void> seek(Duration position) => _service.seek(position);

  Future<void> seekInSeconds(int seconds) async {
    final current = state;
    if (current != null && current.inSeconds + seconds >= 0) {
      await seek(Duration(seconds: current.inSeconds + seconds));
    }
  }
}
