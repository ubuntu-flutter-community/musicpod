import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'play_pause_manager.g.dart';

@Riverpod(keepAlive: true)
class PlayPauseManager extends _$PlayPauseManager {
  PlayPauseManager({PlayerService? playerService})
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
        .whereType<IsPlayingChange>()
        .listen((change) {
          state = change.isPlaying;
        });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return service.isPlaying;
  }

  Future<void> playOrPause() async {
    final service = _playerService;
    if (service == null) return;
    await service.playOrPause();
  }

  Future<void> pause() async {
    final service = _playerService;
    if (service == null) return;
    await service.pause();
  }

  Future<void> resume() async {
    final service = _playerService;
    if (service == null) return;
    await service.resume();
  }

  Future<void> stop() async {
    final service = _playerService;
    if (service == null) return;
    await service.stop();
  }

  Future<void> play({
    required List<Audio> audios,
    required String listName,
    int? index,
  }) async {
    final service = _playerService;
    if (service == null) return;
    await service.play(audios: audios, listName: listName, index: index);
  }
}
