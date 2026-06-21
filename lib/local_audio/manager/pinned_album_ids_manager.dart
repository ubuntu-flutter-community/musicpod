import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import 'local_audio_manager.dart';

@lazySingleton
class PinnedAlbumIDsManager {
  PinnedAlbumIDsManager({required LocalAudioManager localAudioManager}) {
    command = Command.createAsync(
      localAudioManager.togglePinAlbum,
      initialValue: [],
    );
    command.run();

    localAudioManager.initAudiosCommand.listen((_, _) => command.value = []);
  }

  late final Command<int?, List<int>> command;
}
