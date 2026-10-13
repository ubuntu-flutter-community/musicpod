import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../dependencies.dart';
import '../data/audio_progress_state.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'audio_progress_manager.g.dart';

@Riverpod(keepAlive: true)
class AudioProgressManager extends _$AudioProgressManager {
  AudioProgressManager({PlayerService? playerService})
    : _playerServiceOverride = playerService;

  final PlayerService? _playerServiceOverride;
  PlayerService? get _playerService {
    if (_playerServiceOverride != null) return _playerServiceOverride;
    if (di.isRegistered<PlayerService>()) return di<PlayerService>();
    return null;
  }

  StreamSubscription<PlayerChange>? _sub;

  @override
  AudioProgressState build() {
    _sub?.cancel();
    final service = _playerService;
    if (service == null) {
      return const AudioProgressState();
    }

    _sub = service.changes.whereType<LastPositionsChange>().listen((change) {
      state = state.copyWith(
        lastPositions: Map.unmodifiable(change.lastPositions),
      );
    });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return AudioProgressState(
      lastPositions: Map.unmodifiable(service.lastPositions),
    );
  }

  Future<void> toggleAudiosProgress({
    required List<Audio> audios,
    required bool markComplete,
  }) async {
    state = state.copyWith(isToggling: true, hasMissingDuration: false);
    final hasMissing = markComplete && audios.any((a) => a.durationMs == null);
    final service = _playerService;
    try {
      if (service != null) {
        await service.toggleAudiosProgress(audios, markComplete: markComplete);
      }
    } finally {
      state = state.copyWith(
        lastPositions: service != null
            ? Map.unmodifiable(service.lastPositions)
            : const {},
        isToggling: false,
        hasMissingDuration: hasMissing,
      );
    }
  }

  Future<void> clearAll() async {
    final service = _playerService;
    if (service != null) {
      await service.clearAllLastPositions();
    }
    state = state.copyWith(lastPositions: const {});
  }
}
