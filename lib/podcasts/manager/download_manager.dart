import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../common/logging.dart';
import '../../dependencies.dart';
import '../data/download_manager_state.dart';
import '../data/podcast_download.dart';
import '../service/download_service.dart';
import '../service/podcast_service.dart';

part 'download_manager.g.dart';

@Riverpod(keepAlive: true)
class DownloadManager extends _$DownloadManager {
  late final PodcastService _podcastService = di<PodcastService>();
  late final DownloadService _downloadService = di<DownloadService>();

  @override
  Future<DownloadManagerState> build() async {
    Logger.o(tag: '$DownloadManager');
    final dir = await _downloadService.setDownloadsDirectory(getDefault: true);
    return DownloadManagerState(downloadsDirectory: dir);
  }

  bool hasDownload(Audio audio) =>
      _podcastService.getDownloadPath(audio) != null;

  Future<String?> setDownloadsDirectory({bool getDefault = false}) async {
    final dir = await _downloadService.setDownloadsDirectory(
      getDefault: getDefault,
    );
    if (!getDefault) {
      await _podcastService.removeAllDownloads();
    }
    state = AsyncData(
      (state.value ?? const DownloadManagerState()).copyWith(
        downloadsDirectory: dir,
        recentDownloads: getDefault ? null : [],
      ),
    );
    return dir;
  }

  void notifyEvent(PodcastDownload download) {
    final current = state.value ?? const DownloadManagerState();
    final newActive = Set<Audio>.from(current.activeDownloads);
    final newRecent = List<Audio>.from(current.recentDownloads);

    if (download.status == DownloadStatus.inProgress) {
      newActive.add(download.audio);
    } else {
      newActive.remove(download.audio);
      if (download.status == DownloadStatus.completed) {
        if (!newRecent.contains(download.audio)) {
          newRecent.insert(0, download.audio);
        }
      } else if (download.status == DownloadStatus.removed) {
        newRecent.remove(download.audio);
      }
    }

    state = AsyncData(
      current.copyWith(
        activeDownloads: newActive,
        recentDownloads: newRecent,
        lastEvent: download,
      ),
    );
  }
}

@riverpod
class PodcastEpisodeDownloadManager extends _$PodcastEpisodeDownloadManager {
  late final PodcastService _podcastService = di<PodcastService>();
  late final DownloadService _downloadService = di<DownloadService>();

  CancelToken? _cancelToken;

  @override
  Future<PodcastDownload> build(Audio audio) async {
    ref.onDispose(() {
      _cancelToken?.cancel();
      _cancelToken = null;
    });

    final path = _podcastService.getDownloadPath(audio);
    return PodcastDownload.initial(audio: audio, path: path);
  }

  Future<void> startDownload() async {
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;
    state = const AsyncLoading(progress: 0.0);

    ref
        .read(downloadManagerProvider.notifier)
        .notifyEvent(
          PodcastDownload(
            status: DownloadStatus.inProgress,
            audio: audio,
            path: null,
          ),
        );

    try {
      final downloadedPath = await _downloadService.download(
        targetUrl: audio.url!,
        podcastDownloadId: audio.podcastDownloadId,
        cancelToken: cancelToken,
        onProgress: (received, total) {
          if (total > 0) {
            state = AsyncLoading(progress: received / total);
          }
        },
      );

      if (downloadedPath != null) {
        await _podcastService.addDownload(
          url: audio.url!,
          path: downloadedPath,
          feedUrl: audio.feedUrl!,
        );
        final completed = PodcastDownload(
          status: DownloadStatus.completed,
          audio: audio,
          path: downloadedPath,
        );
        state = AsyncData(completed);
        ref.read(downloadManagerProvider.notifier).notifyEvent(completed);
      }
    } on Exception catch (e) {
      final isCancelled = e is DioException && CancelToken.isCancel(e);
      final status = isCancelled
          ? DownloadStatus.cancelled
          : DownloadStatus.removed;
      final event = PodcastDownload(status: status, audio: audio, path: null);
      state = AsyncData(event);
      ref.read(downloadManagerProvider.notifier).notifyEvent(event);
    } finally {
      if (_cancelToken == cancelToken) {
        _cancelToken = null;
      }
    }
  }

  Future<void> removeDownload() async {
    await _podcastService.removeDownload(
      url: audio.url!,
      feedUrl: audio.feedUrl!,
    );
    final removed = PodcastDownload(
      status: DownloadStatus.removed,
      audio: audio,
      path: null,
    );
    state = AsyncData(removed);
    ref.read(downloadManagerProvider.notifier).notifyEvent(removed);
  }

  void cancelDownload() {
    _cancelToken?.cancel();
    _cancelToken = null;
  }

  Future<void> toggleDownload() async {
    if (_cancelToken != null) {
      cancelDownload();
    } else if (state.value?.path != null) {
      await removeDownload();
    } else {
      await startDownload();
    }
  }
}
