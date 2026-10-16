import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'volume_manager.g.dart';

@Riverpod(keepAlive: true)
class VolumeManager extends _$VolumeManager {
  PlayerService get _service => di<PlayerService>();

  StreamSubscription<PlayerChange>? _sub;

  @override
  double? build() {
    _sub?.cancel();

    _sub = _service.changes.whereType<VolumeChange>().listen(
      (change) => state = change.volume,
    );

    ref.onDispose(() => _sub?.cancel());

    return _service.volume ?? 100.0;
  }

  Future<void> setVolume(double value) {
    state = value;
    return _service.setVolume(value);
  }
}
