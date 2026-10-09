import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import 'local_audio_manager.dart';

@Injectable(cache: true)
class HasTracksManager {
  HasTracksManager({required LocalAudioManager localAudioManager}) {
    command = Command.createAsyncNoParam(
      localAudioManager.hasTracks,
      initialValue: true,
    );
    command.run();
  }

  late final Command<void, bool> command;
}
