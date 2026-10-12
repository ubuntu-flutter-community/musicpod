import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../dependencies.dart';
import '../../local_audio/data/playlist_action.dart';
import '../../local_audio/manager/playlist_ids_manager.dart';
import '../../local_audio/service/local_audio_service.dart';
import '../service/custom_content_service.dart';

part 'external_playlist_drafts_manager.g.dart';

@riverpod
class ExternalPlaylistDraftsManager extends _$ExternalPlaylistDraftsManager {
  late final CustomContentService _customContentService =
      di<CustomContentService>();
  late final LocalAudioService _localAudioService = di<LocalAudioService>();

  @override
  Map<String, List<Audio>> build() => {};

  Future<void> addPlaylists() async {
    final more = await _customContentService.loadPlaylistsFromFiles();
    state = {...state, ...more};
  }

  void removePlaylist({required String name}) {
    final updated = Map<String, List<Audio>>.from(state)..remove(name);
    state = updated;
  }

  Future<void> importPlaylists() async {
    for (final entry in state.entries) {
      await _localAudioService.createOrChangePlaylist(
        PlaylistChange(
          id: entry.key,
          audios: entry.value,
          action: PlaylistAction.create,
          external: true,
        ),
      );
    }
    ref.invalidate(playlistIDsManagerProvider);
    state = {};
  }
}
