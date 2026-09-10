import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/family.dart';
import '../service/local_audio_service.dart';

@injectable
class FindAllGenresManager {
  FindAllGenresManager._(LocalAudioService localAudioService)
    : _localAudioService = localAudioService {
    command = Command.createAsyncNoParam(
      _localAudioService.findAllGenres,
      initialValue: null,
    );
    command.run();
  }

  @factoryMethod
  static FindAllGenresManager create(LocalAudioService localAudioService) =>
      Family.of(
        '$FindAllGenresManager',
        () => FindAllGenresManager._(localAudioService),
        shouldDispose: (m) => m.command.listenerCount == 0,
        onDispose: (m) => m.command.dispose(),
      );

  final LocalAudioService _localAudioService;

  late final Command<void, List<String>?> command;
}
