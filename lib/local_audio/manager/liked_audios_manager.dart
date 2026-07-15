import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../app/page_ids.dart';
import '../../common/data/audio.dart';
import '../data/playlist_action.dart';
import 'local_audio_manager.dart';

@Injectable(cache: true)
class LikedAudiosManager {
  LikedAudiosManager(LocalAudioManager localAudioManager) {
    command = Command.createAsync((param) async {
      if (param != null) {
        await localAudioManager.createOrChangeLikedAudios(param);
      }

      return (await localAudioManager.findLikedAudios()) ?? [];
    }, initialValue: []);
    command.run();
  }

  late final Command<PlaylistChange?, List<Audio>> command;

  void addLikedAudios(List<Audio> audios) => command.run(
    PlaylistChange(
      id: PageIDs.likedAudios,
      action: PlaylistAction.addTo,
      audios: audios,
    ),
  );
  void removeLikedAudios(List<Audio> audios) => command.run(
    PlaylistChange(
      id: PageIDs.likedAudios,
      action: PlaylistAction.removeFrom,
      audios: audios,
    ),
  );
}
