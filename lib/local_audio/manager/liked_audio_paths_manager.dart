import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../app/page_ids.dart';
import '../../common/data/audio.dart';
import '../../common/util/family.dart';
import '../data/playlist_action.dart';
import 'liked_audios_manager.dart';
import 'local_audio_manager.dart';

@Injectable(cache: true)
class LikedAudioPathsManager {
  LikedAudioPathsManager({required LocalAudioManager localAudioManager}) {
    command = Command.createAsync((param) async {
      if (param != null) {
        await localAudioManager.createOrChangeLikedAudios(param);
        Family.get<LikedAudiosManager>('$LikedAudiosManager')?.command.run();
      }

      return localAudioManager.findLikedAudioPaths();
    }, initialValue: {});
    command.run();
  }


  late final Command<PlaylistChange?, Set<String>> command;

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
