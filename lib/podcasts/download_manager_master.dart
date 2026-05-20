import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/cached_streamcontroller.dart';
import '../common/logging.dart';
import 'data/podcast_download.dart';
import 'download_service.dart';
import 'podcast_service.dart';

@lazySingleton
class DownloadManagerMaster {
  DownloadManagerMaster({
    required PodcastService podcastService,
    required DownloadService downloadService,
  }) : _podcastService = podcastService,
       _downloadService = downloadService {
    downloadsDirCommand.run((getDefault: true));
    printMessageInDebugMode('Initialized', tag: '$DownloadManagerMaster');
  }

  final PodcastService _podcastService;
  final DownloadService _downloadService;

  late final Command<({bool getDefault}), String?> downloadsDirCommand =
      Command.createAsync((param) async {
        final dir = await _downloadService.setDownloadsDirectory(
          getDefault: param.getDefault,
        );

        if (!param.getDefault) {
          await _podcastService.removeAllDownloads();
        }

        return dir;
      }, initialValue: null);

  final _downloadController = CachedStreamController<PodcastDownload?>();
  PodcastDownload update(PodcastDownload result) {
    _downloadController.add(result);
    return result;
  }

  Stream<PodcastDownload?> get downloadStream => _downloadController.stream;
  PodcastDownload? get lastDownload => _downloadController.value;

  @disposeMethod
  Future<void> dispose() => _downloadController.close();
}
