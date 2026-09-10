import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/family.dart';
import '../service/local_audio_service.dart';

@injectable
class FindAllArtistsManager {
  FindAllArtistsManager._(LocalAudioService localAudioService) {
    command = Command.createAsyncNoParam(
      localAudioService.findAllArtists,
      initialValue: null,
    );
    command.run();
  }

  @factoryMethod
  static FindAllArtistsManager create(LocalAudioService localAudioService) =>
      Family.of(
        '$FindAllArtistsManager',
        () => FindAllArtistsManager._(localAudioService),
        shouldDispose: (m) => m.command.listenerCount == 0,
        onDispose: (m) => m.command.dispose(),
      );

  late final Command<void, List<String>?> command;
}
