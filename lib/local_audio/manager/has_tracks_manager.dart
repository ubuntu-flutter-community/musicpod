import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/family.dart';
import '../../extensions/command_x.dart';
import 'local_audio_manager.dart';

@injectable
class HasTracksManager {
  HasTracksManager._({required LocalAudioManager localAudioManager}) {
    command = Command.createAsyncNoParam(
      localAudioManager.hasTracks,
      initialValue: true,
    );
    command.run();
  }

  @factoryMethod
  static HasTracksManager create({
    required LocalAudioManager localAudioManager,
  }) => Family.of(
    '$HasTracksManager',
    () => HasTracksManager._(localAudioManager: localAudioManager),
    shouldDispose: (m) => m.command.safeToDispose,
    onDispose: (m) => m.command.dispose(),
  );

  late final Command<void, bool> command;
}
