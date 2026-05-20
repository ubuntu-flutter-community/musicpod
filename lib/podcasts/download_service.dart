import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

import '../external_path/external_path_service.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';

@lazySingleton
class DownloadService {
  DownloadService({
    required ExternalPathService externalPathService,
    required SettingsService settingsService,
  }) : _externalPathService = externalPathService,
       _settingsService = settingsService;

  final ExternalPathService _externalPathService;
  final SettingsService _settingsService;

  Future<String?> setDownloadsDirectory({required bool getDefault}) async {
    String? dirError;
    String? directoryPath;

    try {
      if (getDefault) {
        return _settingsService.downloadsDirOrDefault;
      }

      directoryPath = await _externalPathService.getPathOfDirectory();
      if (directoryPath == null) return _settingsService.downloadsDirOrDefault;
      final maybeDir = Directory(directoryPath);
      if (!maybeDir.existsSync()) return _settingsService.downloadsDirOrDefault;
      maybeDir.statSync();
      File(p.join(directoryPath, 'test'))
        ..createSync()
        ..deleteSync();
    } catch (e) {
      dirError = e.toString();
    }

    if (dirError != null) {
      throw Exception('Selected directory is not valid: $dirError');
    } else {
      if (directoryPath != null) {
        await _settingsService.setValue(SPKeys.downloads, directoryPath);
        return _settingsService.downloadsDirOrDefault;
      }
    }

    return null;
  }
}
