import 'dart:typed_data';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import 'local_cover_service.dart';

@lazySingleton
class LocalCoverManager {
  LocalCoverManager({required LocalCoverService localCoverService})
    : _localCoverService = localCoverService {
    initCommand.run();
  }

  final LocalCoverService _localCoverService;

  late final Command<void, Map<int, Uint8List?>> initCommand =
      Command.createAsyncNoParam(
        () => _localCoverService.init(),
        initialValue: {},
      );

  final _getCoverCommands = <int, Command<String, Uint8List?>>{};

  bool shouldRequestCover(int? albumId, String? path) {
    if (albumId == null) return false;
    final command = getCoverCommand(albumId);
    return !command.results.value.hasData && path != null;
  }

  Command<String, Uint8List?> getCoverCommand(int albumId) =>
      _getCoverCommands.putIfAbsent(
        albumId,
        () => Command.createAsync(
          (path) => _localCoverService.getCover(albumId: albumId, path: path),
          initialValue: initCommand.results.value.data?[albumId],
        ),
      );
}
