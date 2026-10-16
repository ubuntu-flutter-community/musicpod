import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'is_video_manager.g.dart';

@Riverpod(keepAlive: true)
class IsVideoManager extends _$IsVideoManager {
  PlayerService get _service => di<PlayerService>();

  StreamSubscription<PlayerChange>? _sub;

  @override
  bool build() {
    _sub?.cancel();

    _sub = _service.changes.whereType<IsVideoChange>().listen((change) {
      state = change.isVideo;
    });

    ref.onDispose(() => _sub?.cancel());

    return _service.isVideo;
  }
}
