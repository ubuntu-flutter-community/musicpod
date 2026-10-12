import 'dart:async';

import 'package:media_kit/media_kit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'playlist_mode_manager.g.dart';

@Riverpod(keepAlive: true)
class PlaylistModeManager extends _$PlaylistModeManager {
  PlaylistModeManager({PlayerService? playerService})
    : _playerServiceOverride = playerService;

  final PlayerService? _playerServiceOverride;
  PlayerService? get _playerService {
    if (_playerServiceOverride != null) return _playerServiceOverride;
    if (di.isRegistered<PlayerService>()) return di<PlayerService>();
    return null;
  }

  StreamSubscription<PlayerChange>? _sub;

  @override
  PlaylistMode build() {
    _sub?.cancel();
    final service = _playerService;
    if (service == null) return PlaylistMode.none;

    _sub = service.changes.whereType<PlaylistModeChange>().listen((change) {
      state = change.playlistMode;
    });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return service.playlistMode;
  }

  void cycle() {
    final service = _playerService;
    if (service == null) return;
    service.setPlaylistMode();
  }
}
