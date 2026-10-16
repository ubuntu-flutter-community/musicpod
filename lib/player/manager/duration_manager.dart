import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'duration_manager.g.dart';

@Riverpod(keepAlive: true)
class DurationManager extends _$DurationManager {
  PlayerService get _service => di<PlayerService>();

  StreamSubscription<PlayerChange>? _sub;

  @override
  Duration? build() {
    _sub?.cancel();

    _sub = _service.changes.whereType<DurationChange>().listen((change) {
      state = change.duration;
    });

    ref.onDispose(() => _sub?.cancel());

    return _service.duration;
  }
}
