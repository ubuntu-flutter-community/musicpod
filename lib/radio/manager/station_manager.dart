import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/data/audio.dart';
import 'radio_manager.dart';

@Injectable(cache: true)
class StationManager {
  StationManager({
    @factoryParam required String uuid,
    required RadioManager radioManager,
  }) {
    command = Command.createAsyncNoParam(
      () => radioManager.getAudioByUUID(uuid),
      initialValue: null,
    );
    command.run();
  }

  late final Command<void, Audio?> command;
}
