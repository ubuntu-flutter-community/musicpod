import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/data/audio.dart';
import '../../common/util/family.dart';
import '../../extensions/command_x.dart';
import 'local_audio_manager.dart';

@injectable
class FindAlbumManager {
  FindAlbumManager._({
    required int albumId,
    required LocalAudioManager localAudioManager,
  }) {
    command = Command.createAsyncNoParam(
      () => localAudioManager.findAlbum(albumId),
      initialValue: null,
    );
    command.run();
  }

  @factoryMethod
  static FindAlbumManager create({
    @factoryParam required int albumId,
    required LocalAudioManager localAudioManager,
  }) => Family.of(
    albumId,
    () => FindAlbumManager._(
      albumId: albumId,
      localAudioManager: localAudioManager,
    ),
    shouldDispose: (m) => m.command.safeToDispose,
    onDispose: (m) => m.command.dispose(),
  );

  late final Command<void, List<Audio>?> command;
}
