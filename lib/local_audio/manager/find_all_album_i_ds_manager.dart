import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/family.dart';
import '../../extensions/command_x.dart';
import '../service/local_audio_service.dart';

@injectable
class FindAllAlbumIDsManager {
  FindAllAlbumIDsManager._(LocalAudioService localAudioService) {
    command = Command.createAsyncNoParam(
      localAudioService.findAllAlbumIDs,
      initialValue: null,
    );
    command.run();
  }

  @factoryMethod
  static FindAllAlbumIDsManager create(LocalAudioService localAudioService) =>
      Family.of(
        '$FindAllAlbumIDsManager',
        () => FindAllAlbumIDsManager._(localAudioService),
        shouldDispose: (m) => m.command.safeToDispose,
        onDispose: (m) => m.command.dispose(),
      );

  late final Command<void, List<int>?> command;
}
