import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'local_audio_service.dart';

@lazySingleton
class PinnedAlbumIDsManager {
  PinnedAlbumIDsManager({required LocalAudioService localAudioService}) {
    command = Command.createAsync(
      localAudioService.togglePinAlbum,
      initialValue: [],
    );
    command.run();
  }

  late final Command<int?, List<int>> command;
}
