import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/family.dart';
import '../../extensions/command_x.dart';
import '../service/local_audio_service.dart';

@injectable
class AlbumIDsOfGenreManager {
  AlbumIDsOfGenreManager._({
    required String genre,
    required LocalAudioService service,
  }) {
    command = Command.createAsyncNoParam(
      () => service.findAlbumIDsOfGenre(genre),
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
    () => AlbumIDsOfGenreManager._(genre: genre, service: service),
    shouldDispose: (m) => m.command.safeToDispose,
    onDispose: (m) => m.command.dispose(),
  );

  late final Command<void, List<int>?> command;
}
