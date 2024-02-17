import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:gtk/gtk.dart';

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
    try {
      readMetadata(File(path), getImage: false).then(
        (data) => _playerService.play.call(
          newAudio: createLocalAudio(path: path, data: data),
        ),
      );
    } catch (_) {
      // TODO: instead of disallowing certain file types
      // process via error stream if something went wrong
    }
  }

  void dispose() {
    _gtkNotifier?.dispose();
  }

  void playOpenedFile() {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      try {
        openFile().then((xfile) {
          if (xfile?.path == null) return;
          readMetadata(File(xfile!.path), getImage: false).then(
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
