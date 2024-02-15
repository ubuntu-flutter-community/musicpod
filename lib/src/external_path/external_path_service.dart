import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:gtk/gtk.dart';
import 'package:metadata_god/metadata_god.dart';

import '../../data.dart';

class ExternalPathService {
  final GtkApplicationNotifier? _gtkNotifier;

  ExternalPathService([this._gtkNotifier]);

  Future<void> Function({Audio? newAudio, Duration? newPosition})? _play;

  void init(
    Future<void> Function({Duration? newPosition, Audio? newAudio}) play,
  ) {
    _play = play;
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
    MetadataGod.initialize();
    try {
      MetadataGod.readMetadata(file: path).then(
        (data) => play.call(
          newAudio: createLocalAudio(path: path, data: data),
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

  void playOpenedFile() {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      try {
        openFile().then((xfile) {
          if (xfile?.path == null) return;
          MetadataGod.initialize();
          MetadataGod.readMetadata(file: xfile!.path).then(
            (metadata) => _play?.call(
              newAudio: createLocalAudio(path: xfile.path, data: metadata),
            ),
          );
        });
      } on Exception catch (_) {}
    }
  }

  Future<String?> getPathOfDirectory() async {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return (await getDirectoryPath());
    }
    return null;
  }
}
