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
  PlayerService get _service => di<PlayerService>();

  StreamSubscription<PlayerChange>? _sub;

  @override
  AudioProgressState build() {
    _sub?.cancel();

    _sub = _service.changes.whereType<LastPositionsChange>().listen((change) {
      state = state.copyWith(
        lastPositions: Map.unmodifiable(change.lastPositions),
      );
    });

    ref.onDispose(() => _sub?.cancel());

    return AudioProgressState(
      lastPositions: Map.unmodifiable(_service.lastPositions),
    );
  }

  Future<void> toggleAudiosProgress({
    required List<Audio> audios,
    required bool markComplete,
  }) async {
    state = state.copyWith(isToggling: true, hasMissingDuration: false);
    final hasMissing = markComplete && audios.any((a) => a.durationMs == null);
    try {
      await _service.toggleAudiosProgress(audios, markComplete: markComplete);
    } finally {
      state = state.copyWith(
        lastPositions: Map.unmodifiable(_service.lastPositions),
        isToggling: false,
        hasMissingDuration: hasMissing,
      );
    }
  }

  Future<void> clearAll() async {
    await _service.clearAllLastPositions();
    state = state.copyWith(lastPositions: const {});
  }
}
