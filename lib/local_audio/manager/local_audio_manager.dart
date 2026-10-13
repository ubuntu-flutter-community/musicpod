import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/local_audio_state.dart';
import '../service/local_audio_service.dart';

part 'local_audio_manager.g.dart';

@Riverpod(keepAlive: true)
class LocalAudioManager extends _$LocalAudioManager {
  late final LocalAudioService _localAudioService = di<LocalAudioService>();

  @override
  Future<LocalAudioState> build() async {
    final result = await _localAudioService.init(
      forceInit: false,
      updateProgress: (p) => state = AsyncLoading(progress: p),
    );
    return LocalAudioState(failedImports: result.failedImports);
  }

  Future<LocalAudioState> initAudios({
    bool forceInit = false,
    String? directory,
  }) async {
    state = const AsyncLoading(progress: 0.0);
    state = await AsyncValue.guard(() async {
      final result = await _localAudioService.init(
        forceInit: forceInit,
        newDirectory: directory,
        updateProgress: (p) => state = AsyncLoading(progress: p),
      );
      return LocalAudioState(failedImports: result.failedImports);
    });
    return state.value ?? const LocalAudioState();
  }
}
