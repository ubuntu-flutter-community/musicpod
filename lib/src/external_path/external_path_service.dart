import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:gtk/gtk.dart';
import 'package:metadata_god/metadata_god.dart';

import '../../data.dart';
import '../../player.dart';

class ExternalPathService {
  final GtkApplicationNotifier? _gtkNotifier;
  final PlayerService _playerService;

  ExternalPathService({
    GtkApplicationNotifier? gtkNotifier,
    required PlayerService playerService,
  })  : _gtkNotifier = gtkNotifier,
        _playerService = playerService;

  void init() {
    if (_gtkNotifier != null) {
      _gtkNotifier!.addCommandLineListener(
        (args) => _playPath(
          _gtkNotifier?.commandLine?.firstOrNull,
        ),
      );
      _playPath(_gtkNotifier?.commandLine?.firstOrNull);
    }
  }

  void _playPath([
    String? path,
  ]) {
    if (path == null) {
      return;
    }
    MetadataGod.initialize();
    try {
      MetadataGod.readMetadata(file: path).then(
        (data) => _playerService.play.call(
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
            (metadata) => _playerService.play(
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
