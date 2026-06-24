import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import '../service/local_audio_service.dart';

@Injectable(cache: true)
class FindAllGenresManager {
  FindAllGenresManager(LocalAudioService localAudioService)
    : _localAudioService = localAudioService {
    command = Command.createAsyncNoParam(
      _localAudioService.findAllGenres,
      initialValue: null,
    );
    command.run();
  }

  final LocalAudioService _localAudioService;

  late final Command<void, List<String>?> command;
}
