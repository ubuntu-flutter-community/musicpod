import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:gtk/gtk.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

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
