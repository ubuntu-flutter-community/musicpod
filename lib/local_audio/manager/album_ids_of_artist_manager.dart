import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/family.dart';
import '../../extensions/command_x.dart';
import '../service/local_audio_service.dart';

@injectable
class AlbumIDsOfArtistManager {
  AlbumIDsOfArtistManager._({
    required String artist,
    required LocalAudioService service,
  }) {
    command = Command.createAsyncNoParam(
      () => service.findAlbumIDsOfArtist(artist),
      initialValue: null,
    );
    command.run(artist);
  }

  @factoryMethod
  static AlbumIDsOfArtistManager create({
    @factoryParam required String artist,
    required LocalAudioService service,
  }) => Family.of(
    artist,
    () => AlbumIDsOfArtistManager._(artist: artist, service: service),
    shouldDispose: (m) => m.command.safeToDispose,
    onDispose: (m) => m.command.dispose(),
  );

  late final Command<void, List<int>?> command;
}
