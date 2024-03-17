import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:gtk/gtk.dart';
import 'package:m3u_parser_nullsafe/m3u_parser_nullsafe.dart';
import 'package:pls/pls.dart';

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
    Set<Audio>? audios;
    String? path;

    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      try {
        final xfile = await openFile();
        path = xfile?.path;
        if (path == null) return (null, null);

        if (path.endsWith('.m3u')) {
          audios = await _parseM3uPlaylist(path);
        } else if (path.endsWith('.pls')) {
          audios = await _parsePlsPlaylist(path);
        }
      } on Exception catch (_) {}
    }
    return (path, audios);
  }

  Future<Set<Audio>> _parseM3uPlaylist(String path) async {
    final audios = <Audio>{};
    final playlist = await M3uList.loadFromFile(path);

    for (var e in playlist.items) {
      String? songName;
      String? artist;
      var split = e.title.split(' - ');
      if (split.isNotEmpty) {
        artist = split.elementAtOrNull(0);
        songName = split.elementAtOrNull(1);
      }

      if (e.link.startsWith('file://')) {
        audios.add(
          Audio.fromMetadata(
            path: path,
            data: (await readMetadata(
              File(e.link.replaceAll('file://', '')),
              getImage: true,
            )),
          ),
        );
      } else if (e.link.startsWith('http')) {
        audios.add(
          Audio(
            title: songName ?? e.title,
            artist: artist,
            url: e.link,
            audioType: AudioType.radio,
          ),
        );
      }
    }

    return audios;
  }

  Future<Set<Audio>> _parsePlsPlaylist(String path) async {
    final audios = <Audio>{};
    final playlist = PlsPlaylist.parse(File(path).readAsStringSync());

    for (var e in playlist.entries) {
      String? songName;
      String? artist;
      var split = e.title?.split(' - ');
      if (split?.isNotEmpty == true) {
        artist = split?.elementAtOrNull(0);
        songName = split?.elementAtOrNull(1);
      }

      if (e.file?.startsWith('http') == true) {
        audios.add(
          Audio(
            title: songName ?? e.title,
            artist: artist,
            url: e.file,
            audioType: AudioType.radio,
          ),
        );
      } else if (e.file?.isNotEmpty == true) {
        audios.add(
          Audio.fromMetadata(
            path: e.file!,
            data: (await readMetadata(File(e.file!), getImage: true)),
          ),
        );
      }
    }

    return audios;
  }

  Future<String?> getPathOfDirectory() async {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return (await getDirectoryPath());
    }
    return null;
  }
}
