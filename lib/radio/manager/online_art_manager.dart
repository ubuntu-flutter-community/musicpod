import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/keep_alive_registry.dart';
import '../service/online_art_service.dart';

@injectable
class OnlineArtManager {
  OnlineArtManager._({
    required String icyTitle,
    required OnlineArtService onlineArtService,
  }) {
    command = Command.createAsyncNoParam(
      () => onlineArtService.fetchAlbumArt(icyTitle: icyTitle),
      initialValue: null,
    );

    command.run();
  }

  @factoryMethod
  static OnlineArtManager create(@factoryParam String icyTitle) =>
      _registry.getOrRegister(
        autoDisposeAfter: const Duration(hours: 5),
        id: icyTitle,
        factoryFunction: () => OnlineArtManager._(
          icyTitle: icyTitle,
          onlineArtService: di<OnlineArtService>(),
        ),
      );

  late final Command<void, String?> command;

  static final _registry = KeepAliveRegistry<String, OnlineArtManager>();
  static void disposeAll() => _registry.disposeAll();
}
