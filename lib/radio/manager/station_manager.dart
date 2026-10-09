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

@Injectable(cache: true)
class StationNameManager {
  StationNameManager({
    @factoryParam required String uuid,
    required RadioManager radioManager,
  }) {
    command = Command.createAsyncNoParam(
      () => radioManager.getStationNameByUUID(uuid),
      initialValue: null,
    );
    command.run();
  }

  late final Command<void, String?> command;
}

@Injectable(cache: true)
class StationImageManager {
  StationImageManager({
    @factoryParam required String uuid,
    required RadioManager radioManager,
  }) {
    command = Command.createAsyncNoParam(
      () => radioManager.getStationImageByUUID(uuid),
      initialValue: null,
    );
    command.run();
  }

  late final Command<void, String?> command;
}
