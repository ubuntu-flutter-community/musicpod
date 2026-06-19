import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/data/audio.dart';
import '../common/keep_alive_registry.dart';
import '../common/logging.dart';
import 'local_audio_manager.dart';
import 'playlist_action.dart';
import 'playlist_i_ds_manager.dart';

@Injectable(cache: true)
class PlaylistManager {
  PlaylistManager({
    @factoryParam required String playlistId,
    required LocalAudioManager localAudioManager,
  }) {
    printInfoInDebugMode(
      '$PlaylistManager created for playlistId: $playlistId',
      tag: '$PlaylistManager',
    );
    command = Command.createAsyncNoParam(
      () => localAudioManager.findPlaylistById(playlistId),
      initialValue: null,
    );
    command.run();

    createOrchangePlaylistCommand = Command.createAsync((param) async {
      await localAudioManager.createOrChangePlaylist(param);
      await di<PlaylistIDsManager>().command.runAsync();
      return di<PlaylistManager>(param1: param.id).command.runAsync();
    }, initialValue: null);
  }

  late final Command<void, List<Audio>?> command;
  static final _registry = KeepAliveRegistry<String, PlaylistManager>();
  void dispose(String playlistId) => _registry.dispose(playlistId);

  late final Command<PlaylistChange, List<Audio>?>
  createOrchangePlaylistCommand;
}
