import 'dart:typed_data';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/family.dart';
import '../service/local_cover_service.dart';

@injectable
class LocalCoverManager {
  LocalCoverManager._({
    required int albumId,
    required LocalCoverService localCoverService,
  }) {
    command = Command.createAsyncNoParam(
      () => localCoverService.getCover(albumId: albumId),
      initialValue: null,
    );
    command.run();
  }

  @factoryMethod
  factory LocalCoverManager.create({
    @factoryParam required int albumId,
    required LocalCoverService localCoverService,
  }) => Family.of(
    albumId,
    () => LocalCoverManager._(
      albumId: albumId,
      localCoverService: localCoverService,
    ),
    shouldDispose: (m) => m.command.listenerCount == 0,
    onDispose: (m) => m.command.dispose(),
  );

  late final Command<void, Uint8List?> command;
}
