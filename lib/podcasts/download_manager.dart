import 'package:dio/dio.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/logging.dart';
import 'data/podcast_download.dart';
import 'download_manager_master.dart';
import 'podcast_service.dart';

@Injectable(cache: true)
class DownloadManager extends SafeChangeNotifier {
  DownloadManager({
    required PodcastService podcastService,
    required DownloadManagerMaster master,
  }) : _podcastService = podcastService,
       _master = master {
    printMessageInDebugMode('Initialized', tag: '$DownloadManager');
  }

  final PodcastService _podcastService;
  final DownloadManagerMaster _master;

  final commands = MapNotifier<Audio, Command<void, PodcastDownload?>>(
    notificationMode: CustomNotifierMode.manual,
  );

  bool hasDownload(Audio audio) {
    final downloadCommand = getCommand(audio);
    return downloadCommand.value?.status == DownloadStatus.completed &&
        downloadCommand.value?.path != null;
  }

  Command<void, PodcastDownload?> getCommand(Audio media) =>
      commands.putIfAbsent(media, () => _createDownloadCommand(media));

  Command<void, PodcastDownload> _createDownloadCommand(Audio media) =>
      Command.createAsyncNoParamWithProgress(
        (handle) async {
          final cancelToken = CancelToken();

          try {
            if (_podcastService.getDownloadFilePaths(media.url) == null) {
              handle.isCanceled.listen((canceled, subscription) {
                if (canceled) {
                  handle.updateProgress(0.0);
                  cancelToken.cancel();
                  subscription.cancel();
                }
              });
              _master.update(
                PodcastDownload(
                  status: DownloadStatus.inProgress,
                  audio: media,
                  path: null,
                ),
              );
              final download = await _podcastService.download(
                episode: media,
                cancelToken: cancelToken,
                onProgress: (received, total) {
                  handle.updateProgress(received / total);
                },
              );
              return _master.update(
                PodcastDownload(
                  status: DownloadStatus.completed,
                  audio: media,
                  path: download,
                ),
              );
            } else {
              await _podcastService.removeDownload(
                url: media.url!,
                feedUrl: media.feedUrl!,
              );

              return _master.update(
                PodcastDownload(
                  status: DownloadStatus.removed,
                  audio: media,
                  path: null,
                ),
              );
            }
          } on Exception catch (_) {
            return _master.update(
              PodcastDownload(
                status: DownloadStatus.cancelled,
                audio: media,
                path: null,
              ),
            );
          } finally {
            commands.notifyListeners();
          }
        },

        initialValue: PodcastDownload(
          status: _podcastService.getDownloadFilePaths(media.url) != null
              ? DownloadStatus.completed
              : DownloadStatus.removed,
          audio: media,
          path: _podcastService.getDownloadFilePaths(media.url),
        ),
      );
}
