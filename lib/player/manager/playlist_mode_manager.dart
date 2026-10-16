import 'dart:async';

import 'package:media_kit/media_kit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'playlist_mode_manager.g.dart';

@Riverpod(keepAlive: true)
class PlaylistModeManager extends _$PlaylistModeManager {
  PlayerService get _service => di<PlayerService>();

  StreamSubscription<PlayerChange>? _sub;

  @override
  PlaylistMode build() {
    _sub?.cancel();

    _sub = _service.changes.whereType<PlaylistModeChange>().listen((change) {
      state = change.playlistMode;
    });

    ref.onDispose(() => _sub?.cancel());

    return _service.playlistMode;
  }

  void cycle() => _service.setPlaylistMode();
}
