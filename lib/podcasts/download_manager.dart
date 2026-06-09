import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/cached_streamcontroller.dart';
import '../common/data/audio.dart';
import '../common/logging.dart';
import 'data/podcast_download.dart';
import 'download_service.dart';
import 'podcast_service.dart';

@lazySingleton
class DownloadManager {
  DownloadManager({
    required PodcastService podcastService,
    required DownloadService downloadService,
  }) : _podcastService = podcastService,
       _downloadService = downloadService {
    downloadsDirCommand.run((getDefault: true));
    printInfoInDebugMode('Instance created', tag: '$DownloadManager');
  }

  final PodcastService _podcastService;
  final DownloadService _downloadService;

  final downloadCommands = MapNotifier<Audio, Command<void, PodcastDownload?>>(
    notificationMode: CustomNotifierMode.manual,
  );

  bool hasDownload(Audio audio) =>
      getCommand(audio).value?.isDownload(audio) ?? false;

  Command<void, PodcastDownload?> getCommand(Audio audio) =>
      downloadCommands.putIfAbsent(audio, () => _createDownloadCommand(audio));

  Command<void, PodcastDownload> _createDownloadCommand(Audio audio) =>
      Command.createAsyncNoParamWithProgress(
        (handle) async {
          final cancelToken = CancelToken();

          try {
            if (_podcastService.getDownloadPath(audio) == null) {
              handle.isCanceled.listen((canceled, subscription) {
                if (canceled) {
                  handle.updateProgress(0.0);
                  cancelToken.cancel();
                  subscription.cancel();
                }
              });
              _updateStream(
                PodcastDownload(
                  status: DownloadStatus.inProgress,
                  audio: audio,
                  path: null,
                ),
              );
              final theDownload = await this.download(
                episode: audio,
                cancelToken: cancelToken,
                onProgress: (received, total) {
                  handle.updateProgress(received / total);
                },
              );
              return _updateStream(
                PodcastDownload(
                  status: DownloadStatus.completed,
                  audio: audio,
                  path: theDownload,
                ),
              );
            } else {
              await _podcastService.removeDownload(
                url: audio.url!,
                feedUrl: audio.feedUrl!,
              );

              return _updateStream(
                PodcastDownload(
                  status: DownloadStatus.removed,
                  audio: audio,
                  path: null,
                ),
              );
            }
          } on Exception catch (_) {
            return _updateStream(
              PodcastDownload(
                status: DownloadStatus.cancelled,
                audio: audio,
                path: null,
              ),
            );
          } finally {
            downloadCommands.notifyListeners();
          }
        },
        initialValue: PodcastDownload.initial(
          audio: audio,
          path: _podcastService.getDownloadPath(audio),
        ),
      );

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
  PodcastDownload _updateStream(PodcastDownload result) {
    _downloadController.add(result);
    return result;
  }

  Stream<PodcastDownload?> get downloadStream => _downloadController.stream;
  PodcastDownload? get lastDownload => _downloadController.value;

  Future<String?> download({
    required Audio episode,
    required CancelToken cancelToken,
    required void Function(int received, int total) onProgress,
  }) async {
    final targetUrl = episode.url;
    final feedUrl = episode.feedUrl;
    if (targetUrl == null || feedUrl == null) {
      throw Exception('Invalid media, missing URL or feed URL for download');
    }

    final path = await _downloadService.download(
      targetUrl: targetUrl,
      podcastDownloadId: episode.podcastDownloadId,
      cancelToken: cancelToken,
      onProgress: onProgress,
    );

    if (path != null) {
      await _podcastService.addDownload(
        url: targetUrl,
        path: path,
        feedUrl: feedUrl,
      );
      return path;
    }

    return null;
  }

  @disposeMethod
  Future<void> dispose() => _downloadController.close();
}
