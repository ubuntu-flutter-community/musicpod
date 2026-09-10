import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/data/audio.dart';
import '../../common/util/family.dart';
import 'radio_manager.dart';

@injectable
class StationManager {
  StationManager._({
    required String uuid,
    required RadioManager radioManager,
  }) {
    command = Command.createAsyncNoParam(
      () => radioManager.getAudioByUUID(uuid),
      initialValue: null,
    );
    command.run();
  }

  @factoryMethod
  static StationManager create({
    @factoryParam required String uuid,
    required RadioManager radioManager,
  }) => Family.of(
    uuid,
    () => StationManager._(
      uuid: uuid,
      radioManager: radioManager,
    ),
    shouldDispose: (m) => m.command.listenerCount == 0,
    onDispose: (m) => m.command.dispose(),
  );

  late final Command<void, Audio?> command;
}

@injectable
class StationNameManager {
  StationNameManager._({
    required String uuid,
    required RadioManager radioManager,
  }) {
    command = Command.createAsyncNoParam(
      () => radioManager.getStationNameByUUID(uuid),
      initialValue: null,
    );
    command.run();
  }

  @factoryMethod
  static StationNameManager create({
    @factoryParam required String uuid,
    required RadioManager radioManager,
  }) => Family.of(
    uuid,
    () => StationNameManager._(
      uuid: uuid,
      radioManager: radioManager,
    ),
    shouldDispose: (m) => m.command.listenerCount == 0,
    onDispose: (m) => m.command.dispose(),
  );

  late final Command<void, String?> command;
}

@injectable
class StationImageManager {
  StationImageManager._({
    required String uuid,
    required RadioManager radioManager,
  }) {
    command = Command.createAsyncNoParam(
      () => radioManager.getStationImageByUUID(uuid),
      initialValue: null,
    );
    command.run();
  }

  @factoryMethod
  static StationImageManager create({
    @factoryParam required String uuid,
    required RadioManager radioManager,
  }) => Family.of(
    uuid,
    () => StationImageManager._(
      uuid: uuid,
      radioManager: radioManager,
    ),
    shouldDispose: (m) => m.command.listenerCount == 0,
    onDispose: (m) => m.command.dispose(),
  );

  late final Command<void, String?> command;
}
