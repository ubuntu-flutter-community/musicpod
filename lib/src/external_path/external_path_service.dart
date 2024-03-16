import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:gtk/gtk.dart';
import 'package:m3u_parser_nullsafe/m3u_parser_nullsafe.dart';

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
      readMetadata(File(path), getImage: true).then(
        (data) => _playerService.play.call(
          newAudio: Audio.fromMetadata(path: path, data: data),
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
          readMetadata(File(xfile!.path), getImage: true).then(
            (metadata) => _playerService.play(
              newAudio: Audio.fromMetadata(path: xfile.path, data: metadata),
            ),
          );
        });
      } on Exception catch (_) {}
    }
  }

  Future<(String?, Set<Audio>?)> loadPlaylistFromFile() async {
    final audios = <Audio>{};
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      try {
        final xfile = await openFile();
        if (xfile?.path == null) return (null, null);

        final playlist = await M3uList.loadFromFile(xfile!.path);

        for (var e in playlist.items) {
          String? songName;
          String? artist;
          var split = e.title.split(' - ');
          if (split.isNotEmpty) {
            artist = split.elementAtOrNull(0);
            songName = split.elementAtOrNull(1);
          }
          audios.add(
            Audio(
              title: songName ?? e.title,
              artist: artist,
              path: e.link.startsWith('file://')
                  ? e.link.replaceAll('file://', '')
                  : null,
              url: e.link.startsWith('http') ? e.link : null,
              audioType: e.link.startsWith('file://')
                  ? AudioType.local
                  : e.link.startsWith('http')
                      ? AudioType.radio
                      : null,
            ),
          );
        }

        return (xfile.path, audios);
      } on Exception catch (_) {
        return (null, null);
      }
    }
    return (null, null);
  }

  Future<String?> getPathOfDirectory() async {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return (await getDirectoryPath());
    }
    return null;
  }
}
