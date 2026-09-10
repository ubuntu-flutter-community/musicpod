import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/family.dart';
import '../service/local_audio_service.dart';

@injectable
class AlbumIDsOfGenreManager {
  AlbumIDsOfGenreManager._({
    required String genre,
    required LocalAudioService service,
  }) {
    command = Command.createAsync(
      (genre) => service.findAlbumIDsOfGenre(genre),
      initialValue: null,
    );

    command.run(genre);
  }

  @factoryMethod
  static AlbumIDsOfGenreManager create({
    @factoryParam required String genre,
    required LocalAudioService service,
  }) => Family.of(
    genre,
    () => AlbumIDsOfGenreManager._(
      genre: genre,
      service: service,
    ),
    shouldDispose: (m) => m.command.listenerCount == 0,
    onDispose: (m) => m.command.dispose(),
  );

  late final Command<String, List<int>?> command;
}
