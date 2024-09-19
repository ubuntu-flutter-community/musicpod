import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../l10n/l10n.dart';
import '../library/library_service.dart';

class DownloadModel extends SafeChangeNotifier {
  DownloadModel({
    required LibraryService libraryService,
    required Dio dio,
  })  : _service = libraryService,
        _dio = dio;

  final LibraryService _service;
  final Dio _dio;

  final _values = <String, double?>{};
  final _cancelTokens = <String, CancelToken?>{};

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

  Future<void> deleteDownload({
    required BuildContext context,
    required Audio? audio,
  }) async {
    if (audio?.url != null &&
        _service.downloadsDir != null &&
        audio?.website != null) {
      _service.removeDownload(url: audio!.url!, feedUrl: audio.website!);
      if (_values.containsKey(audio.url)) {
        _values.update(audio.url!, (value) => null);
      }

      notifyListeners();
    }
  }

  Future<void> startDownload({
    required BuildContext context,
    required Audio? audio,
  }) async {
    final downloadsDir = _service.downloadsDir;
    if (audio?.url == null || downloadsDir == null) return;
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
      context: context,
      url: url,
      path: path,
      name: audio.title ?? '',
    ).then((response) {
      if (response?.statusCode == 200 && audio.website != null) {
        _service.addDownload(url: url, path: path, feedUrl: audio.website!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.downloadFinished(audio.title ?? '')),
            ),
          );
        }
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
    required BuildContext context,
    required String url,
    required String path,
    required String name,
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
        message = context.l10n.downloadCancelled(name);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message ?? e.toString())));
      }
      return null;
    }
  }
}
