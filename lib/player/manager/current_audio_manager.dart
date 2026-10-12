import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'current_audio_manager.g.dart';

@Riverpod(keepAlive: true)
class CurrentAudioManager extends _$CurrentAudioManager {
  CurrentAudioManager({PlayerService? playerService})
      : _playerServiceOverride = playerService;

  final PlayerService? _playerServiceOverride;
  PlayerService? get _playerService {
    if (_playerServiceOverride != null) return _playerServiceOverride;
    if (di.isRegistered<PlayerService>()) return di<PlayerService>();
    return null;
  }

  StreamSubscription<PlayerChange>? _sub;

  @override
  Audio? build() {
    _sub?.cancel();
    final service = _playerService;
    if (service == null) return null;

    _sub = service.changes
        .whereType<AudioChange>()
        .listen((change) {
          state = change.audio;
        });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return service.audio;
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

  Future<void> safeCurrentAudioPosition() async {
    final service = _playerService;
    if (service == null) return;
    await service.safeCurrentAudioPosition();
  }
}
