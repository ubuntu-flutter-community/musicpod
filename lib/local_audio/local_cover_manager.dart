import 'dart:typed_data';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/logging.dart';
import 'local_cover_service.dart';

@Injectable(cache: true)
class LocalCoverManager {
  LocalCoverManager({required LocalCoverService localCoverService})
    : _localCoverService = localCoverService {
    printInfoInDebugMode('Instance created', tag: '$LocalCoverManager');
  }

  final LocalCoverService _localCoverService;

  final _getCoverCommands = <int, Command<void, Uint8List?>>{};

  Command<void, Uint8List?> getCoverCommand(int albumId) =>
      _getCoverCommands.putIfAbsent(
        albumId,
        () => Command.createAsync(
          (_) => _localCoverService.getCover(albumId: albumId),
          initialValue: null,
        ),
      );

  bool shouldRequestCover(int? albumId) {
    if (albumId == null) return false;
    final command = getCoverCommand(albumId);
    return !command.results.value.hasData;
  }
}
