import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../common/data/audio.dart';
import 'local_audio_manager.dart';

@Injectable(cache: true)
class PlaylistManager {
  PlaylistManager({
    @factoryParam required String playlistId,
    required LocalAudioManager localAudioManager,
  }) {
    command = Command.createAsyncNoParam(
      () => localAudioManager.findPlaylistById(playlistId),
      initialValue: null,
    );
    command.run();
  }

  late final Command<void, List<Audio>?> command;

  final showPlaylistAddAudios = SafeValueNotifier<bool>(false);
  void toggleShowPlaylistAddAudios() =>
      showPlaylistAddAudios.value = !showPlaylistAddAudios.value;
}
