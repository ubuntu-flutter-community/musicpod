import 'dart:io';

import 'package:dio/dio.dart';
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

  Future<void> startDownload(
    Audio? audio,
  ) async {
    _service.dio.interceptors.add(LogInterceptor());
    // Assure the value of total argument of onReceiveProgress is not -1.
    _service.dio.options.headers = {HttpHeaders.acceptEncodingHeader: '*'};
    final downloadsDir = _service.downloadsDir;

    if (audio?.url == null || downloadsDir == null) return;

    final downloadDir = p.join(downloadsDir, 'musicpod');

    if (!Directory(downloadDir).existsSync()) {
      Directory(downloadDir).createSync();
    }
    final fileName =
        '${audio?.artist}${audio?.title}${audio?.year}'.replaceAll(' ', '_');
    final file = File(
      p.join(
        downloadDir,
        fileName,
      ),
    );
    file.createSync();

    download1(_service.dio, audio!.url!, file.path);
  }

  Future download1(Dio dio, String url, String path) async {
    final cancelToken = CancelToken();
    try {
      await dio
          .download(
            url,
            path,
            onReceiveProgress: setValue,
            cancelToken: cancelToken,
          )
          .then((_) => _service.addDownload(url, path));
    } catch (e) {
      //TODO: manage download exception
    }
  }
}
