import 'dart:io';

import 'package:collection/collection.dart';
import 'package:gtk/gtk.dart';
import 'package:id3tag/id3tag.dart';

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
    if (path == null) {
      return;
    }
    try {
      final metadata = ID3TagReader.path(path).readTagSync();
      play.call(
        newAudio: createLocalAudio(
          path: path,
          tag: metadata,
          fileName: File(path).uri.pathSegments.last,
        ),
      );
    } catch (_) {
      // TODO: instead of disallowing certain file types
      // process via error stream if something went wrong
    }
  }

  Future<void> dispose() async {
    _gtkNotifier?.dispose();
  }
}
