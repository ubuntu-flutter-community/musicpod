import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/family.dart';
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
  static OnlineArtManager create(@factoryParam String icyTitle) => Family.of(
    icyTitle,
    () => OnlineArtManager._(
      icyTitle: icyTitle,
      onlineArtService: di<OnlineArtService>(),
    ),
    shouldDispose: (t) => t.command.listenerCount == 0,
    autoDisposeAfter: const Duration(hours: 5),
  );

  late final Command<void, String?> command;

  static void disposeAll() => Family.disposeAll<OnlineArtManager>();
}
