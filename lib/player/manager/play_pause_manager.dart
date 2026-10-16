import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'play_pause_manager.g.dart';

@Riverpod(keepAlive: true)
class PlayPauseManager extends _$PlayPauseManager {
  PlayerService get _service => di<PlayerService>();

  StreamSubscription<PlayerChange>? _sub;

  @override
  bool build() {
    _sub?.cancel();

    _sub = _service.changes.whereType<IsPlayingChange>().listen((change) {
      state = change.isPlaying;
    });

    ref.onDispose(() => _sub?.cancel());

    return _service.isPlaying;
  }

  Future<void> playOrPause() => _service.playOrPause();

  Future<void> pause() => _service.pause();

  Future<void> resume() => _service.resume();

  Future<void> stop() => _service.stop();

  Future<void> play({
    required List<Audio> audios,
    required String listName,
    int? index,
  }) => _service.play(audios: audios, listName: listName, index: index);
}
