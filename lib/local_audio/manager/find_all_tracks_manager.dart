import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../dependencies.dart';
import '../service/local_audio_service.dart';
import 'local_audio_manager.dart';

part 'find_all_tracks_manager.g.dart';

@riverpod
class FindAllTracksManager extends _$FindAllTracksManager {
  @override
  Future<List<Audio>> build() async {
    await ref.watch(localAudioManagerProvider.future);
    return di<LocalAudioService>().findAllTracks();
  }
}
