import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/playlist_action.dart';
import '../service/local_audio_service.dart';
import 'local_audio_manager.dart';
import 'playlist_manager.dart';

part 'playlist_ids_manager.g.dart';

@Riverpod(keepAlive: true)
class PlaylistIDsManager extends _$PlaylistIDsManager {
  late final LocalAudioService _service = di<LocalAudioService>();

  @override
  Future<List<String>> build() async {
    await ref.watch(localAudioManagerProvider.future);
    return _service.findAllPlaylistIDs();
  }

  Future<void> createOrChangePlaylist(PlaylistChange param) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _service.createOrChangePlaylist(param);
      ref.invalidate(playlistManagerProvider(param.id));
      return _service.findAllPlaylistIDs();
    });
  }
}
