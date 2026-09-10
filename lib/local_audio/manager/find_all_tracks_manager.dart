import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/data/audio.dart';
import '../../common/util/family.dart';
import 'local_audio_manager.dart';

@injectable
class FindAllTracksManager {
  FindAllTracksManager._(LocalAudioManager localAudioManager) {
    command = Command.createAsyncNoParam(
      localAudioManager.findAllTracks,
      initialValue: null,
    );
    command.run();
  }

  @factoryMethod
  static FindAllTracksManager create(LocalAudioManager localAudioManager) =>
      Family.of(
        '$FindAllTracksManager',
        () => FindAllTracksManager._(localAudioManager),
        shouldDispose: (m) => m.command.listenerCount == 0,
        onDispose: (m) => m.command.dispose(),
      );

  late final Command<void, List<Audio>?> command;
}
