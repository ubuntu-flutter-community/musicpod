import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/logging.dart';
import '../extensions/build_context_x.dart';
import '../external_path/external_path_service.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';
import 'data/podcast_download.dart';
import 'podcast_service.dart';

@lazySingleton
class DownloadManagerMaster {
  final _downloadController = StreamController<PodcastDownload>.broadcast();
  void addDownloadResult(PodcastDownload result) =>
      _downloadController.add(result);
  Stream<PodcastDownload> get downloadStream => _downloadController.stream;

  @disposeMethod
  Future<void> dispose() => _downloadController.close();
}

@Injectable(cache: true)
class DownloadManager extends SafeChangeNotifier {
  DownloadManager({
    required PodcastService podcastService,
    required SettingsService settingsService,
    required Dio dio,
    required ExternalPathService externalPathService,
    required DownloadManagerMaster master,
  }) : _podcastService = podcastService,
       _settingsService = settingsService,
       _master = master,
       _externalPathService = externalPathService {
    downloadsDirCommand.run((setNewDir: false));
    printMessageInDebugMode('Initialized', tag: '$DownloadManager');
  }

  final PodcastService _podcastService;
  final SettingsService _settingsService;
  final ExternalPathService _externalPathService;
  final DownloadManagerMaster _master;

  final downloadCommands = MapNotifier<Audio, Command<void, PodcastDownload?>>(
    notificationMode: CustomNotifierMode.manual,
  );

  bool hadDownload(Audio audio) =>
      _podcastService.getDownload(audio.url) != null;

  Command<void, PodcastDownload?> getDownloadCommand(Audio media) =>
      downloadCommands.putIfAbsent(media, () => _createDownloadCommand(media));

  Command<void, PodcastDownload> _createDownloadCommand(Audio media) {
    final Command<void, PodcastDownload> command =
        Command.createAsyncNoParamWithProgress(
          (handle) async {
            final cancelToken = CancelToken();

            try {
              if (_podcastService.getDownload(media.url) == null) {
                handle.isCanceled.listen((canceled, subscription) {
                  if (canceled) {
                    handle.updateProgress(0.0);
                    cancelToken.cancel();
                    subscription.cancel();
                  }
                });
                final podcastDownloadResult = PodcastDownload(
                  status: PodcastDownloadStatus.downloaded,
                  audio: media,
                  path: await _podcastService.download(
                    episode: media,
                    cancelToken: cancelToken,
                    onProgress: (received, total) {
                      handle.updateProgress(received / total);
                    },
                  ),
                );
                _master.addDownloadResult(podcastDownloadResult);
                return podcastDownloadResult;
              } else {
                await _podcastService.removeDownload(
                  url: media.url!,
                  feedUrl: media.feedUrl!,
                );
                final podcastDownloadResult = PodcastDownload(
                  status: PodcastDownloadStatus.removed,
                  audio: media,
                  path: null,
                );

                _master.addDownloadResult(podcastDownloadResult);
                return podcastDownloadResult;
              }
            } on Exception catch (_) {
              final podcastDownloadResult = PodcastDownload(
                status: PodcastDownloadStatus.cancelled,
                audio: media,
                path: null,
              );
              _master.addDownloadResult(podcastDownloadResult);
              return podcastDownloadResult;
            }
          },

          initialValue: PodcastDownload(
            status: _podcastService.getDownload(media.url) != null
                ? PodcastDownloadStatus.downloaded
                : PodcastDownloadStatus.removed,
            audio: media,
            path: _podcastService.getDownload(media.url),
          ),
        );

    return command;
  }

  late final Command<({bool setNewDir}), String?> downloadsDirCommand =
      Command.createAsync((param) async {
        if (!param.setNewDir) {
          return _settingsService.downloadsDirOrDefault;
        }

        final dir = await setDownloadsCustomDir();
        await _podcastService.removeAllDownloads();
        return dir;
      }, initialValue: null);

  Future<String?> setDownloadsCustomDir() async {
    String? dirError;
    String? directoryPath;

    try {
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
}

void downloadMessageStreamHandler(
  BuildContext context,
  AsyncSnapshot<String?> snapshot,
  void Function() cancel,
) {
  if (snapshot.hasData) {
    context.toast(Text(snapshot.data ?? ''));
  }
}
