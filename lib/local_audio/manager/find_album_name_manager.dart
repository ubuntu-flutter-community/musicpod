import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import 'local_audio_manager.dart';

@Injectable(cache: true)
class FindAlbumNameManager {
  FindAlbumNameManager({
    @factoryParam required int albumId,
    required LocalAudioManager localAudioManager,
  }) {
    command = Command.createAsyncNoParam(
      () => localAudioManager.findAlbumName(albumId),
      initialValue: null,
    );
    command.run();
  }

  late final Command<void, String?> command;
}
