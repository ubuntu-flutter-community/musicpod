import 'dart:io';

import 'package:dio/dio.dart';
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
    required Dio dio,
  }) : _externalPathService = externalPathService,
       _settingsService = settingsService,
       _dio = dio;

  final ExternalPathService _externalPathService;
  final SettingsService _settingsService;
  final Dio _dio;

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

  Future<String?> download({
    required String targetUrl,
    required String podcastDownloadId,
    required CancelToken cancelToken,
    required void Function(int received, int total) onProgress,
  }) async {
    final downloadsDir = await _settingsService.downloadsDirOrDefault;
    if (downloadsDir == null) {
      throw Exception('Downloads directory not set');
    }

    if (!Directory(downloadsDir).existsSync()) {
      Directory(downloadsDir).createSync(recursive: true);
    }

    final path = p.join(downloadsDir, podcastDownloadId);

    final response = await _dio.download(
      targetUrl,
      path,
      onReceiveProgress: onProgress,
      cancelToken: cancelToken,
    );

    if (response.statusCode == 200) {
      return path;
    }

    return null;
  }
}
