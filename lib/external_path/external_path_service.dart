import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app_config.dart';

class ExternalPathService {
  const ExternalPathService();

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
