import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../data/playlist_action.dart';
import 'local_audio_manager.dart';
import 'playlist_manager.dart';

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

    localAudioManager.initAudiosCommand.listen((_, _) => command.value = []);

    command.run();
  }

  late final Command<PlaylistChange?, List<String>> command;
}
