import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/family.dart';
import '../../extensions/command_x.dart';
import 'local_audio_manager.dart';

@injectable
class FindArtistOfAlbumManager {
  FindArtistOfAlbumManager._({
    required int albumId,
    required LocalAudioManager localAudioManager,
  }) {
    command = Command.createAsyncNoParam(
      () => localAudioManager.findArtistOfAlbum(albumId),
      initialValue: null,
    );
    command.run();
  }

  @factoryMethod
  static FindArtistOfAlbumManager create({
    @factoryParam required int albumId,
    required LocalAudioManager localAudioManager,
  }) => Family.of(
    albumId,
    () => FindArtistOfAlbumManager._(
      albumId: albumId,
      localAudioManager: localAudioManager,
    ),
    shouldDispose: (m) => m.command.safeToDispose,
    onDispose: (m) => m.command.dispose(),
  );

  late final Command<void, String?> command;
}
