import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../service/local_audio_service.dart';

@Injectable(cache: true)
class AlbumIDsOfGenreManager {
  AlbumIDsOfGenreManager({
    @factoryParam required String genre,
    required LocalAudioService service,
  }) {
    command = Command.createAsyncNoParam(
      () => service.findAlbumIDsOfGenre(genre),
      initialValue: null,
    );

    command.run(genre);
  }

  late final Command<void, List<int>?> command;
}
