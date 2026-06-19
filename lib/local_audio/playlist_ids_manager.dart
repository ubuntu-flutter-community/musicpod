import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/data/audio.dart';
import 'find_playlist_manager.dart';
import 'local_audio_manager.dart';
import 'playlist_action.dart';

@lazySingleton
class PlaylistIDsManager {
  PlaylistIDsManager({required LocalAudioManager localAudioManager}) {
    command = Command.createAsync((param) async {
      if (param != null) {
        await localAudioManager.createOrChangePlaylist(param);

        await di<PlaylistManager>(param1: param.id).command.runAsync();
      }

      return localAudioManager.findAllPlaylistIDs();
    }, initialValue: []);

    command.run();
  }

  late final Command<PlaylistChange?, List<String>> command;
}

@Injectable(cache: true)
class ImportExternalPlaylistManager {
  ImportExternalPlaylistManager({
    required LocalAudioManager localAudioManager,
  }) {
    command = Command.createAsyncNoResult((playlists) async {
      for (final playlist in playlists) {
        await localAudioManager.createOrChangePlaylist(
          PlaylistChange(
            id: playlist.id,
            audios: playlist.audios,
            action: PlaylistAction.create,
            external: true,
          ),
        );
        await di<PlaylistIDsManager>().command.runAsync();
      }
    });
  }

  late final Command<List<({String id, List<Audio> audios})>, void> command;
}
