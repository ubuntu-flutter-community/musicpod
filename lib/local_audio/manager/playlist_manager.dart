import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../common/data/audio.dart';
import '../../common/util/family.dart';
import 'local_audio_manager.dart';

@injectable
class PlaylistManager {
  PlaylistManager._({
    required String playlistId,
    required LocalAudioManager localAudioManager,
  }) {
    command = Command.createAsyncNoParam(
      () => localAudioManager.findPlaylistById(playlistId),
      initialValue: null,
    );
    command.run();
  }

  @factoryMethod
  static PlaylistManager create({
    @factoryParam required String playlistId,
    required LocalAudioManager localAudioManager,
  }) => Family.of(
    playlistId,
    () => PlaylistManager._(
      playlistId: playlistId,
      localAudioManager: localAudioManager,
    ),
    shouldDispose: (t) => t.command.listenerCount == 0,
  );

  late final Command<void, List<Audio>?> command;

  final showPlaylistAddAudios = SafeValueNotifier<bool>(false);
  void toggleShowPlaylistAddAudios() =>
      showPlaylistAddAudios.value = !showPlaylistAddAudios.value;
}
