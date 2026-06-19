import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'local_audio_service.dart';

@lazySingleton
class PlaylistIDsManager {
  PlaylistIDsManager({required LocalAudioService localAudioService}) {
    command = Command.createAsyncNoParam(
      () => localAudioService.findAllPlaylistIDs(),
      initialValue: [],
    );
    command.run();
  }

  late final Command<void, List<String>> command;
}
