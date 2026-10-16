import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'current_audio_manager.g.dart';

@Riverpod(keepAlive: true)
class CurrentAudioManager extends _$CurrentAudioManager {
  PlayerService get _service => di<PlayerService>();

  StreamSubscription<PlayerChange>? _sub;

  @override
  Audio? build() {
    _sub?.cancel();

    _sub = _service.changes.whereType<AudioChange>().listen((change) {
      state = change.audio;
    });

    ref.onDispose(() => _sub?.cancel());

    return _service.audio;
  }

  Future<void> play({
    required List<Audio> audios,
    required String listName,
    int? index,
  }) => _service.play(audios: audios, listName: listName, index: index);

  Future<void> safeCurrentAudioPosition() =>
      _service.safeCurrentAudioPosition();
}
