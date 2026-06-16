import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import 'local_audio_service.dart';

@Injectable(cache: true)
class AlbumIDsOfArtistManager {
  AlbumIDsOfArtistManager({
    @factoryParam required String artist,
    required LocalAudioService service,
  }) {
    command = Command.createAsync(
      (artist) => service.findAlbumIDsOfArtist(artist),
      initialValue: null,
    );
    command.run(artist);
  }

  late final Command<String, List<int>?> command;
}
