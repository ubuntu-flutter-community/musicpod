import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/data/audio.dart';
import '../common/keep_alive_registry.dart';
import 'radio_service.dart';

@injectable
class StationManager {
  StationManager._({required String uuid, required RadioService radioService}) {
    _registry.register(id: uuid, instance: this);
    command = Command.createAsyncNoParam(
      () => radioService.getAudioByUUID(uuid),
      initialValue: null,
    );
    command.run();
  }

  late final Command<void, Audio?> command;

  @factoryMethod
  static StationManager create({
    @factoryParam required String uuid,
    required RadioService radioService,
  }) =>
      _registry.get(uuid) ??
      StationManager._(uuid: uuid, radioService: radioService);

  static final _registry = KeepAliveRegistry<String, StationManager>();
  static StationManager? dispose(String uuid) => _registry.dispose(uuid);
}
