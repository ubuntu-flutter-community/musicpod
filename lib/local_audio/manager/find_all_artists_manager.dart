import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import '../local_audio_service.dart';

@Injectable(cache: true)
class FindAllArtistsManager {
  FindAllArtistsManager(LocalAudioService localAudioService) {
    command = Command.createAsyncNoParam(
      localAudioService.findAllArtists,
      initialValue: null,
    );
    command.run();
  }

  late final Command<void, List<String>?> command;
}
