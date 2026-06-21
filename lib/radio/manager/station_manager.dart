import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/data/audio.dart';
import '../../common/keep_alive_registry.dart';
import 'radio_manager.dart';

@injectable
class StationManager {
  StationManager._({required String uuid, required RadioManager radioManager}) {
    command = Command.createAsyncNoParam(
      () => radioManager.getAudioByUUID(uuid),
      initialValue: null,
    );
    command.run();
    radioManager.wipeCommand.listen((_, sub) {
      dispose(uuid);
      sub.cancel();
    });
  }

  late final Command<void, Audio?> command;

  @factoryMethod
  static StationManager create({
    @factoryParam required String uuid,
    required RadioManager radioManager,
  }) => _registry.getOrRegister(
    id: uuid,
    factoryFunction: () =>
        StationManager._(uuid: uuid, radioManager: radioManager),
  );

  static final _registry = KeepAliveRegistry<String, StationManager>();
  static StationManager? dispose(String uuid) => _registry.dispose(uuid);
}
