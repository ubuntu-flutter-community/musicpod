import 'dart:io';

import 'package:gtk/gtk.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:mime/mime.dart';

import '../../data.dart';
import '../../utils.dart';

class ExternalPathService {
  final GtkApplicationNotifier? _gtkNotifier;

  ExternalPathService([this._gtkNotifier]);

  Future<void> init(
    Future<void> Function({Duration? newPosition, Audio? newAudio}) play,
  ) async {
    if (_gtkNotifier != null) {
      _gtkNotifier?.addCommandLineListener(
        (args) => playPath(
          play: play,
        ),
      );
    }
  }

  void playPath({
    required Future<void> Function({Duration? newPosition, Audio? newAudio})
        play,
  }) {
    final path = _gtkNotifier?.commandLine?.firstOrNull;
    if (path == null || !_isValidAudio(path)) {
      return;
    }

    MetadataGod.initialize();
    try {
      MetadataGod.readMetadata(file: path).then(
        (metadata) => play(
          newAudio: createLocalAudio(
            path,
            metadata,
            File(path).uri.pathSegments.last,
          ),
        ),
      );
    } catch (_) {}
  }

  bool _isValidAudio(String path) {
    final mime = lookupMimeType(path);
    return mime?.startsWith('audio/') ?? false;
  }

  Future<void> dispose() async {
    _gtkNotifier?.dispose();
  }
}
