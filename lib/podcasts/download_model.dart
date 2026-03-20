import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:path/path.dart' as p;
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/view/snackbars.dart';
import '../extensions/taget_platform_x.dart';
import '../external_path/external_path_service.dart';
import '../library/library_service.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';

class DownloadModel extends SafeChangeNotifier {
  DownloadModel({
    required LibraryService libraryService,
    required SettingsService settingsService,
    required Dio dio,
    required ExternalPathService externalPathService,
  }) : _libraryService = libraryService,
       _settingsService = settingsService,
       _dio = dio,
       _externalPathService = externalPathService {
    downloadsDirCommand.run((setNewDir: false));
  }

  final LibraryService _libraryService;
  final SettingsService _settingsService;
  final Dio _dio;
  final ExternalPathService _externalPathService;

  final _values = <String, double?>{};
  final _cancelTokens = <String, CancelToken?>{};
  final _messageStreamController = StreamController<String>.broadcast();
  String _lastMessage = '';
  void _addMessage(String message) {
    if (message == _lastMessage) return;
    _lastMessage = message;
    _messageStreamController.add(message);
  }

  Stream<String> get messageStream => _messageStreamController.stream;

  double? getValue(String? url) => _values[url];
  void setValue({
    required int received,
    required int total,
    required String url,
  }) {
    if (total <= 0) return;
    final v = received / total;
    _values.containsKey(url)
        ? _values.update(url, (value) => v)
        : _values.putIfAbsent(url, () => v);

    notifyListeners();
  }

  late final Command<({bool setNewDir}), String?> downloadsDirCommand =
      Command.createAsync((param) async {
        if (!param.setNewDir) {
          return _downloadsDirOrDefault;
        }

        final dir = await setDownloadsCustomDir();
        await deleteAllDownloads();
        return dir;
      }, initialValue: null);

  Future<String?> setDownloadsCustomDir() async {
    String? dirError;
    String? directoryPath;

    try {
      directoryPath = await _externalPathService.getPathOfDirectory();
      if (directoryPath == null) return _downloadsDirOrDefault;
      final maybeDir = Directory(directoryPath);
      if (!maybeDir.existsSync()) return _downloadsDirOrDefault;
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
        return _downloadsDirOrDefault;
      }
    }

    return null;
  }

  Future<String?> get _downloadsDirOrDefault async =>
      _settingsService.getString(SPKeys.downloads) ??
      await PlatformX.downloadsDefaultDir;

  Future<void> deleteDownload({required Audio? audio}) async {
    if (audio?.url != null &&
        (downloadsDirCommand.value) != null &&
        audio?.website != null) {
      _libraryService.removeDownload(url: audio!.url!, feedUrl: audio.website!);
      if (_values.containsKey(audio.url)) {
        _values.update(audio.url!, (value) => null);
      }

      notifyListeners();
    }
  }

  Future<void> deleteAllDownloads() async {
    if ((downloadsDirCommand.value) != null) {
      _libraryService.removeAllDownloads();
      _values.clear();

      notifyListeners();
    }
  }

  Future<void> startDownload({
    required Audio? audio,
    required String canceledMessage,
    required String finishedMessage,
  }) async {
    final downloadsDir = downloadsDirCommand.value;
    if (downloadsDir == null) {
      _addMessage('No downloads directory set');
      return;
    }
    if (audio?.url == null) return;
    final url = audio!.url!;

    if (_cancelTokens[url] != null) {
      _cancelTokens[url]?.cancel();
      _values.containsKey(url)
          ? _values.update(url, (value) => null)
          : _values.putIfAbsent(url, () => null);
      _cancelTokens.update(url, (value) => null);
      notifyListeners();
      return;
    }

    _dio.interceptors.add(LogInterceptor());
    _dio.options.headers = {HttpHeaders.acceptEncodingHeader: '*'};

    if (!Directory(downloadsDir).existsSync()) {
      Directory(downloadsDir).createSync();
    }

    final path = p.join(downloadsDir, _createAudioDownloadId(audio));
    await _download(
      canceledMessage: canceledMessage,
      url: url,
      path: path,
      name: audio.title ?? '',
    ).then((response) {
      if (response?.statusCode == 200 && audio.website != null) {
        _libraryService.addDownload(
          url: url,
          path: path,
          feedUrl: audio.website!,
        );
        _addMessage(finishedMessage);

        _cancelTokens.containsKey(url)
            ? _cancelTokens.update(url, (value) => null)
            : _cancelTokens.putIfAbsent(url, () => null);
      }
    });
  }

  String _createAudioDownloadId(Audio audio) {
    final now = DateTime.now().toUtc().toString();
    return '${audio.artist ?? ''}${audio.title ?? ''}${audio.durationMs ?? ''}${audio.year ?? ''})$now'
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }

  Future<Response<dynamic>?> _download({
    required String url,
    required String path,
    required String name,
    required String canceledMessage,
  }) async {
    _cancelTokens.containsKey(url)
        ? _cancelTokens.update(url, (value) => CancelToken())
        : _cancelTokens.putIfAbsent(url, () => CancelToken());
    try {
      return await _dio.download(
        url,
        path,
        onReceiveProgress: (count, total) =>
            setValue(received: count, total: total, url: url),
        cancelToken: _cancelTokens[url],
      );
    } catch (e) {
      _cancelTokens[url]?.cancel();

      String? message;
      if (e.toString().contains('[request cancelled]')) {
        message = canceledMessage;
      }

      _addMessage(message ?? e.toString());
      return null;
    }
  }

  @override
  Future<void> dispose() async {
    await _messageStreamController.close();
    super.dispose();
  }
}

void downloadMessageStreamHandler(
  BuildContext context,
  AsyncSnapshot<String?> snapshot,
  void Function() cancel,
) {
  if (snapshot.hasData) {
    showSnackBar(context: context, content: Text(snapshot.data ?? ''));
  }
}
