import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/family.dart';
import 'local_audio_manager.dart';

@injectable
class FindAlbumNameManager {
  FindAlbumNameManager._({
    required int albumId,
    required LocalAudioManager localAudioManager,
  }) {
    command = Command.createAsyncNoParam(
      () => localAudioManager.findAlbumName(albumId),
      initialValue: null,
    );
    command.run();
  }

  @factoryMethod
  static FindAlbumNameManager create({
    @factoryParam required int albumId,
    required LocalAudioManager localAudioManager,
  }) => Family.of(
    albumId,
    () => FindAlbumNameManager._(
      albumId: albumId,
      localAudioManager: localAudioManager,
    ),
    shouldDispose: (m) => m.command.listenerCount == 0,
    onDispose: (m) => m.command.dispose(),
  );

  late final Command<void, String?> command;
}
