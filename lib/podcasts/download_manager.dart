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

  bool hasDownload(Audio audio) =>
      getCommand(audio).value?.isDownload(audio) ?? false;

  Command<void, PodcastDownload?> getCommand(Audio audio) =>
      commands.putIfAbsent(audio, () => _createDownloadCommand(audio));

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
              _master.update(
                PodcastDownload(
                  status: DownloadStatus.inProgress,
                  audio: audio,
                  path: null,
                ),
              );
              final download = await _podcastService.download(
                episode: audio,
                cancelToken: cancelToken,
                onProgress: (received, total) {
                  handle.updateProgress(received / total);
                },
              );
              return _master.update(
                PodcastDownload(
                  status: DownloadStatus.completed,
                  audio: audio,
                  path: download,
                ),
              );
            } else {
              await _podcastService.removeDownload(
                url: audio.url!,
                feedUrl: audio.feedUrl!,
              );

              return _master.update(
                PodcastDownload(
                  status: DownloadStatus.removed,
                  audio: audio,
                  path: null,
                ),
              );
            }
          } on Exception catch (_) {
            return _master.update(
              PodcastDownload(
                status: DownloadStatus.cancelled,
                audio: audio,
                path: null,
              ),
            );
          } finally {
            commands.notifyListeners();
          }
        },
        initialValue: PodcastDownload.initial(
          audio: audio,
          path: _podcastService.getDownloadPath(audio),
        ),
      );
}
