import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'shuffle_manager.g.dart';

@Riverpod(keepAlive: true)
class ShuffleManager extends _$ShuffleManager {
  PlayerService get _service => di<PlayerService>();

  StreamSubscription<PlayerChange>? _sub;

  @override
  bool build() {
    _sub?.cancel();

    _sub = _service.changes.whereType<ShuffleChange>().listen((change) {
      state = change.shuffle;
    });

    ref.onDispose(() => _sub?.cancel());

    return _service.shuffle;
  }

  Future<void> toggle() => _service.setShuffle(!state);

  Future<void> setShuffle(bool value) => _service.setShuffle(value);
}
