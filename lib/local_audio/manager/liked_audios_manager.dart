import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../app/page_ids.dart';
import '../../common/data/audio.dart';
import '../data/playlist_action.dart';
import 'local_audio_manager.dart';

@Injectable(cache: true)
class LikedAudiosManager {
  LikedAudiosManager(LocalAudioManager localAudioManager) {
    command = Command.createAsyncNoParam(
      localAudioManager.findLikedAudios,
      initialValue: null,
    );
    command.run();

    changeLikedAudiosCommand = Command.createAsync((param) async {
      if (param != null) {
        await localAudioManager.createOrChangeLikedAudios(param);
      }

      return await command.runAsync() ?? [];
    }, initialValue: []);
  }

  late final Command<void, List<Audio>?> command;

  void addLikedAudios(List<Audio> audios) => changeLikedAudiosCommand.run(
    PlaylistChange(
      id: PageIDs.likedAudios,
      action: PlaylistAction.addTo,
      audios: audios,
    ),
  );
  void removeLikedAudios(List<Audio> audios) => changeLikedAudiosCommand.run(
    PlaylistChange(
      id: PageIDs.likedAudios,
      action: PlaylistAction.removeFrom,
      audios: audios,
    ),
  );

  late final Command<PlaylistChange?, List<Audio>> changeLikedAudiosCommand;
}
