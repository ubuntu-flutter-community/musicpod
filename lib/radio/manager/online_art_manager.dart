import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../service/online_art_service.dart';

@Injectable(cache: true)
class OnlineArtManager {
  OnlineArtManager({
    @factoryParam required String icyTitle,
    required OnlineArtService onlineArtService,
  }) {
    command = Command.createAsyncNoParam(
      () => onlineArtService.fetchAlbumArt(icyTitle: icyTitle),
      initialValue: null,
    );

    command.run();
  }

  late final Command<void, String?> command;
}
