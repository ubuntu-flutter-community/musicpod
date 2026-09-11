import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../app/page_ids.dart';
import '../../common/data/audio.dart';
import '../../common/util/family.dart';
import '../../extensions/command_x.dart';
import '../data/playlist_action.dart';
import 'liked_audio_paths_manager.dart';
import 'local_audio_manager.dart';

@injectable
class LikedAudiosManager {
  LikedAudiosManager._({
    required LocalAudioManager localAudioManager,
    required LikedAudioPathsManager pathsManager,
  }) {
    command = Command.createAsync((param) async {
      if (param != null) {
        await localAudioManager.createOrChangeLikedAudios(param);
        pathsManager.command.run();
      }

      return (await localAudioManager.findLikedAudios()) ?? [];
    }, initialValue: []);
    command.run();
  }

  @factoryMethod
  static LikedAudiosManager create({
    required LocalAudioManager localAudioManager,
    required LikedAudioPathsManager pathsManager,
  }) => Family.of(
    '$LikedAudiosManager',
    () => LikedAudiosManager._(
      localAudioManager: localAudioManager,
      pathsManager: pathsManager,
    ),
    shouldDispose: (m) => m.command.safeToDispose,
    onDispose: (m) => m.command.dispose(),
  );

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
