import 'dart:typed_data';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/logging.dart';
import 'local_cover_service.dart';

@Injectable(cache: true)
class LocalCoverManager {
  LocalCoverManager({required LocalCoverService localCoverService})
    : _localCoverService = localCoverService {
    printMessageInDebugMode('Instance created', tag: '$LocalCoverManager');
  }

  final LocalCoverService _localCoverService;

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
          initialValue: null,
        ),
      );
}
