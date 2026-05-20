import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../extensions/build_context_x.dart';
import '../external_path/external_path_service.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';
import 'data/podcast_download_result.dart';
import 'podcast_service.dart';

@Injectable(cache: true)
class DownloadManager extends SafeChangeNotifier {
  DownloadManager({
    required PodcastService podcastService,
    required SettingsService settingsService,
    required Dio dio,
    required ExternalPathService externalPathService,
  }) : _podcastService = podcastService,
       _settingsService = settingsService,

       _externalPathService = externalPathService {
    downloadsDirCommand.run((setNewDir: false));
  }

  final PodcastService _podcastService;
  final SettingsService _settingsService;
  final ExternalPathService _externalPathService;

  final downloadCommands =
      MapNotifier<Audio, Command<void, PodcastDownloadResult?>>(
        notificationMode: CustomNotifierMode.manual,
      );

  final _downloadController =
      StreamController<PodcastDownloadResult>.broadcast();
  Stream<PodcastDownloadResult> get downloadStream =>
      _downloadController.stream;

  bool hadDownload(Audio audio) =>
      _podcastService.getDownload(audio.url) != null;

  Command<void, PodcastDownloadResult?> getDownloadCommand(Audio media) =>
      downloadCommands.putIfAbsent(media, () => _createDownloadCommand(media));

  Command<void, PodcastDownloadResult> _createDownloadCommand(Audio media) {
    final Command<void, PodcastDownloadResult> command =
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
                final podcastDownloadResult = PodcastDownloadResult(
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
                _downloadController.add(podcastDownloadResult);
                return podcastDownloadResult;
              } else {
                await _podcastService.removeDownload(
                  url: media.url!,
                  feedUrl: media.feedUrl!,
                );
                final podcastDownloadResult = PodcastDownloadResult(
                  status: PodcastDownloadStatus.removed,
                  audio: media,
                  path: null,
                );

                _downloadController.add(podcastDownloadResult);
                return podcastDownloadResult;
              }
            } on Exception catch (_) {
              final podcastDownloadResult = PodcastDownloadResult(
                status: PodcastDownloadStatus.cancelled,
                audio: media,
                path: null,
              );
              _downloadController.add(podcastDownloadResult);
              return podcastDownloadResult;
            } finally {
              downloadCommands.notifyListeners();
            }
          },

          initialValue: PodcastDownloadResult(
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
