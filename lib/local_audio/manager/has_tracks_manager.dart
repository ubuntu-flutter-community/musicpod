import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/local_audio_service.dart';
import 'local_audio_manager.dart';

part 'has_tracks_manager.g.dart';

@riverpod
class HasTracksManager extends _$HasTracksManager {
  @override
  Future<bool> build() async {
    await ref.watch(localAudioManagerProvider.future);
    return di<LocalAudioService>().hasTracks();
  }
}
