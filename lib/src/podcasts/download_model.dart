import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:path/path.dart' as p;

import '../../data.dart';
import '../../library.dart';

class DownloadModel extends SafeChangeNotifier {
  DownloadModel(this._service);

  final LibraryService _service;

  double? _value;
  double? get value => _value;
  void setValue(int received, int total) {
    if (total <= 0) return;
    _value = received / total;
    notifyListeners();
  }

  Future<void> deleteDownload({
    required BuildContext context,
    required Audio? audio,
  }) async {
    if (audio?.url != null || _service.downloadsDir != null) {
      _service.removeDownload(audio!.url!);
    }
  }

  Future<void> startDownload({
    required BuildContext context,
    required Audio? audio,
  }) async {
    final downloadsDir = _service.downloadsDir;
    if (audio?.url == null || downloadsDir == null) return;
    if (_cancelToken != null) {
      _cancelToken?.cancel();
      _value = null;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Download canceled')));
      notifyListeners();
      return;
    }

    _service.dio.interceptors.add(LogInterceptor());
    _service.dio.options.headers = {HttpHeaders.acceptEncodingHeader: '*'};

    if (!Directory(downloadsDir).existsSync()) {
      Directory(downloadsDir).createSync();
    }

    final url = audio!.url!;
    final path = p.join(downloadsDir, audio.toShortPath());
    await _download(
      context: context,
      url: url,
      path: path,
    ).then((response) {
      if (response?.statusCode == 200) {
        _service.addDownload(url, path);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Download Finished')));
        _cancelToken = null;
      }
    });
  }

  CancelToken? _cancelToken;
  Future<Response<dynamic>?> _download({
    required BuildContext context,
    required String url,
    required String path,
  }) async {
    _cancelToken = CancelToken();
    try {
      return await _service.dio.download(
        url,
        path,
        onReceiveProgress: setValue,
        cancelToken: _cancelToken,
      );
    } catch (e) {
      _cancelToken?.cancel();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      return null;
    }
  }
}
