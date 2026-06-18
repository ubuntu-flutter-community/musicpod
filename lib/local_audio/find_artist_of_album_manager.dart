import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/keep_alive_registry.dart';
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
  }) => _registry.getOrRegister(
    id: albumId,
    factoryFunction: () => FindArtistOfAlbumManager._(
      albumId: albumId,
      localAudioManager: localAudioManager,
    ),
  );

  late final Command<void, String?> command;
  static final _registry = KeepAliveRegistry<int, FindArtistOfAlbumManager>();
  void dispose(int albumId) => _registry.dispose(albumId);
}
