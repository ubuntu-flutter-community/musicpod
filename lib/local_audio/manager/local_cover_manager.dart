import 'dart:typed_data';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../service/local_cover_service.dart';

@Injectable(cache: true)
class LocalCoverManager {
  LocalCoverManager({
    @factoryParam required int albumId,
    required LocalCoverService localCoverService,
  }) {
    command = Command.createAsyncNoParam(
      () => localCoverService.getCover(albumId: albumId),
      initialValue: null,
    );
    command.run();
  }

  late final Command<void, Uint8List?> command;
}
