import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:permission_handler/permission_handler.dart';

import '../extensions/taget_platform_x.dart';

class ExternalPathService {
  const ExternalPathService();

  Future<String?> getPathOfDirectory() async {
    if (isMobile && await _androidPermissionsGranted()) {
      return FilePicker.platform.getDirectoryPath();
    }

    if (isMacOS || isLinux || isWindows) {
      return getDirectoryPath();
    }
    return null;
  }

  Future<String?> getPathOfFile() async {
    if (isMobile && await _androidPermissionsGranted()) {
      return (await FilePicker.platform.pickFiles(
        allowMultiple: false,
      ))?.files.firstOrNull?.path;
    }

    if (isMacOS || isLinux || isWindows) {
      return (await openFile())?.path;
    }
    return null;
  }

  Future<List<String>> getPathsOfFiles() async {
    if (isMobile && await _androidPermissionsGranted()) {
      final filePickerResult = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );

      if (filePickerResult == null) {
        return [];
      }

      return filePickerResult.files
          .map((e) => XFile(e.path!))
          .map((e) => e.path)
          .toList();
    } else if (isMacOS || isLinux || isWindows) {
      return (await openFiles()).map((e) => e.path).toList();
    }
    return [];
  }

  Future<bool> _androidPermissionsGranted() async =>
      (await Permission.audio
              .onDeniedCallback(() {})
              .onGrantedCallback(() {})
              .onPermanentlyDeniedCallback(() {})
              .onRestrictedCallback(() {})
              .onLimitedCallback(() {})
              .onProvisionalCallback(() {})
              .request())
          .isGranted;
}
