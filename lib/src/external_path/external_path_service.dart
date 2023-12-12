import 'dart:io';

import 'package:collection/collection.dart';
import 'package:gtk/gtk.dart';
import 'package:metadata_god/metadata_god.dart';

import '../../data.dart';
import '../../utils.dart';

class ExternalPathService {
  final GtkApplicationNotifier? _gtkNotifier;

  ExternalPathService([this._gtkNotifier]);

  void init(
    Future<void> Function({Duration? newPosition, Audio? newAudio}) play,
  ) {
    if (_gtkNotifier != null) {
      _gtkNotifier!.addCommandLineListener(
        (args) => playPath(
          play,
          _gtkNotifier?.commandLine?.firstOrNull,
        ),
      );
      playPath(play, _gtkNotifier?.commandLine?.firstOrNull);
    }
  }

  void playPath(
    Future<void> Function({Audio? newAudio, Duration? newPosition}) play, [
    String? path,
  ]) {
    if (path == null || !isValidFile(path)) {
      return;
    }
    MetadataGod.initialize();
    try {
      MetadataGod.readMetadata(file: path).then(
        (metadata) => play.call(
          newAudio: createLocalAudio(
            path,
            metadata,
            File(path).uri.pathSegments.last,
          ),
        ),
      );
    } catch (_) {}
  }

  Future<void> dispose() async {
    _gtkNotifier?.dispose();
  }
}
