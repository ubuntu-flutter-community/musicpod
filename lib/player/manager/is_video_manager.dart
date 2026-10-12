import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'is_video_manager.g.dart';

@Riverpod(keepAlive: true)
class IsVideoManager extends _$IsVideoManager {
  IsVideoManager({PlayerService? playerService})
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
        .whereType<IsVideoChange>()
        .listen((change) {
          state = change.isVideo;
        });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return service.isVideo;
  }
}
