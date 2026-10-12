import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../dependencies.dart';
import '../service/local_audio_service.dart';
import 'local_audio_manager.dart';

part 'playlist_manager.g.dart';

@riverpod
class PlaylistManager extends _$PlaylistManager {
  @override
  Future<List<Audio>?> build(String playlistId) async {
    await ref.watch(localAudioManagerProvider.future);
    return di<LocalAudioService>().findPlaylistById(playlistId);
  }
}
