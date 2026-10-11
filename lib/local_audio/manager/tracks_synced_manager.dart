import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/local_audio_service.dart';
import 'local_audio_manager.dart';

part 'tracks_synced_manager.g.dart';

@Riverpod(keepAlive: true)
class TracksSyncedManager extends _$TracksSyncedManager {
  late final LocalAudioService _service = di<LocalAudioService>();

  @override
  Future<bool> build() async {
    await ref.watch(localAudioManagerProvider.future);
    return _service.areTracksSynced();
  }

  Future<bool> checkTracksSynced() async {
    state = const AsyncLoading();
    final synced = await AsyncValue.guard(_service.areTracksSynced);
    state = synced;
    return synced.value ?? true;
  }
}
