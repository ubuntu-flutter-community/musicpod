import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:gtk/gtk.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app_config.dart';
import '../common/data/audio.dart';
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

      if (file.existsSync() && file.isPlayable) {
        _playerService.startPlaylist(
          listName: path,
          audios: [Audio.local(file, getImage: true)],
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

  Future<String?> getPathOfFile() async {
    if (AppConfig.isMobilePlatform && await _androidPermissionsGranted()) {
      return (await FilePicker.platform.pickFiles(allowMultiple: false))
          ?.files
          .firstOrNull
          ?.path;
    }

    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return (await openFile())?.path;
    }
    return null;
  }

  Future<List<String>> getPathsOfFiles() async {
    if (AppConfig.isMobilePlatform && await _androidPermissionsGranted()) {
      final filePickerResult =
          await FilePicker.platform.pickFiles(allowMultiple: true);

      if (filePickerResult == null) {
        return [];
      }

      return filePickerResult.files
          .map((e) => XFile(e.path!))
          .map((e) => e.path)
          .toList();
    } else if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return (await openFiles()).map((e) => e.path).toList();
    }
    return [];
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
