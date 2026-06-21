import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/keep_alive_registry.dart';
import 'local_audio_manager.dart';

@injectable
class FindAlbumNameManager {
  FindAlbumNameManager._({
    required int albumId,
    required LocalAudioManager localAudioManager,
  }) {
    command = Command.createAsyncNoParam(
      () => localAudioManager.findAlbumName(albumId),
      initialValue: null,
    );
    command.run();
  }

  @factoryMethod
  static FindAlbumNameManager create({
    @factoryParam required int albumId,
    required LocalAudioManager localAudioManager,
  }) => _registry.getOrRegister(
    id: albumId,
    factoryFunction: () => FindAlbumNameManager._(
      albumId: albumId,
      localAudioManager: localAudioManager,
    ),
  );

  late final Command<void, String?> command;
  static final _registry = KeepAliveRegistry<int, FindAlbumNameManager>();
  void dispose(int albumId) => _registry.dispose(albumId);
}
