import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/data/audio.dart';
import 'local_audio_manager.dart';

@Injectable(cache: true)
class FindAllTracksManager {
  FindAllTracksManager(LocalAudioManager localAudioManager) {
    command = Command.createAsyncNoParam(
      localAudioManager.findAllTracks,
      initialValue: null,
    );
    command.run();
  }

  late final Command<void, List<Audio>?> command;
}
