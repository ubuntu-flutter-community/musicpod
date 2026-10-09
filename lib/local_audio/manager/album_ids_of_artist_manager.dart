import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../service/local_audio_service.dart';

@Injectable(cache: true)
class AlbumIDsOfArtistManager {
  AlbumIDsOfArtistManager({
    @factoryParam required String artist,
    required LocalAudioService service,
  }) {
    command = Command.createAsyncNoParam(
      () => service.findAlbumIDsOfArtist(artist),
      initialValue: null,
    );
    command.run(artist);
  }

  late final Command<void, List<int>?> command;
}
