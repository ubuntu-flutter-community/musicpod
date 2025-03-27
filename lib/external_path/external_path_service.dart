import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:gtk/gtk.dart';
import 'package:m3u_parser_nullsafe/m3u_parser_nullsafe.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pls/pls.dart';

import '../app_config.dart';
import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../common/logging.dart';
import '../extensions/media_file_x.dart';
import '../player/player_service.dart';

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
      final file = File(path);

      if (file.couldHaveMetadata) {
        _playerService.startPlaylist(
          listName: path,
          audios: [
            Audio.fromMetadata(
              path: file.path,
              data: readMetadata(file, getImage: true),
            ),
          ],
        );
      } else if (file.isPlayable) {
        _playerService.startPlaylist(
          listName: path,
          audios: [
            Audio(
              path: file.path,
              title: basename(file.path),
              audioType: AudioType.local,
            ),
          ],
        );
      }
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }
  }

  void dispose() {
    _gtkNotifier?.dispose();
  }

  void playOpenedFile() {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      try {
        openFile().then((xfile) {
          if (xfile == null) return;

          if (xfile.couldHaveMetadata) {
            _playerService.startPlaylist(
              listName: xfile.path,
              audios: [
                Audio.fromMetadata(
                  path: xfile.path,
                  data: readMetadata(File(xfile.path), getImage: true),
                ),
              ],
            );
          } else if (xfile.isPlayable) {
            _playerService.startPlaylist(
              listName: xfile.path,
              audios: [
                Audio(
                  path: xfile.path,
                  title: basename(xfile.path),
                  audioType: AudioType.local,
                ),
              ],
            );
          }
        });
      } on Exception catch (e) {
        printMessageInDebugMode(e);
      }
    }
  }

  Future<(String?, List<Audio>?)> loadPlaylistFromFile() async {
    List<Audio>? audios;
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
      } on Exception catch (e) {
        printMessageInDebugMode(e);
      }
    }
    return (path, audios);
  }

  Future<List<Audio>> _parseM3uPlaylist(String path) async {
    final audios = <Audio>[];
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
        final file = File(e.link.replaceAll('file://', ''));
        if (file.couldHaveMetadata) {
          audios.add(
            Audio.fromMetadata(
              path: path,
              data: readMetadata(
                file,
                getImage: true,
              ),
            ),
          );
        } else if (file.isPlayable) {
          audios.add(
            Audio(
              path: path,
              title: basename(path),
              audioType: AudioType.local,
            ),
          );
        }
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

  Future<List<Audio>> _parsePlsPlaylist(String path) async {
    final audios = <Audio>[];
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
        final file = File(e.file!);
        if (file.couldHaveMetadata) {
          audios.add(
            Audio.fromMetadata(
              path: e.file!,
              data: readMetadata(file, getImage: true),
            ),
          );
        } else if (file.isPlayable) {
          audios.add(
            Audio(
              path: file.path,
              title: basename(path),
              audioType: AudioType.local,
            ),
          );
        }
      }
    }

    return audios;
  }

  Future<String?> getPathOfDirectory() async {
    if (AppConfig.isMobilePlatform && await _androidPermissionsGranted()) {
      return FilePicker.platform.getDirectoryPath();
    }

    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return getDirectoryPath();
    }
    return null;
  }

  Future<bool> _androidPermissionsGranted() async {
    final mediaLibraryIsGranted = (await Permission.mediaLibrary
            .onDeniedCallback(() {})
            .onGrantedCallback(() {})
            .onPermanentlyDeniedCallback(() {})
            .onRestrictedCallback(() {})
            .onLimitedCallback(() {})
            .onProvisionalCallback(() {})
            .request())
        .isGranted;

    final manageExternalStorageIsGranted = (await Permission
            .manageExternalStorage
            .onDeniedCallback(() {})
            .onGrantedCallback(() {})
            .onPermanentlyDeniedCallback(() {})
            .onRestrictedCallback(() {})
            .onLimitedCallback(() {})
            .onProvisionalCallback(() {})
            .request())
        .isGranted;

    return mediaLibraryIsGranted && manageExternalStorageIsGranted;
  }
}
