import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import 'local_audio_manager.dart';

@Injectable(cache: true)
class FindArtistOfAlbumManager {
  FindArtistOfAlbumManager({
    @factoryParam required int albumId,
    required LocalAudioManager localAudioManager,
  }) {
    command = Command.createAsyncNoParam(
      () => localAudioManager.findArtistOfAlbum(albumId),
      initialValue: null,
    );
    command.run();
  }

  late final Command<void, String?> command;
}
