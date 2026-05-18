import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../l10n/app_localizations.dart';
import 'podcast_service.dart';

@singleton
class PodcastManager {
  PodcastManager({required PodcastService podcastService})
    : _podcastService = podcastService {
    togglePodcastCommand.run();
    feedsWithDownloadsCommand.run();
    Command.globalExceptionHandler = (e, s) {};
  }

  final PodcastService _podcastService;

  late final Command<({bool forceInit}), void> initSearchCommand =
      Command.createSyncNoResult(
        (param) =>
            _podcastService.initSearchProvider(forceInit: param.forceInit),
      );

  final updatesOnly = SafeValueNotifier<bool>(false);
  void setUpdatesOnly(bool value) {
    if (updatesOnly.value == value) return;
    updatesOnly.value = value;
  }

  final downloadsOnly = SafeValueNotifier<bool>(false);
  void setDownloadsOnly(bool value) {
    if (downloadsOnly.value == value) return;
    downloadsOnly.value = value;
  }

  void toggleDownloadsOnly() => setDownloadsOnly(!downloadsOnly.value);

  final showSearch = SafeValueNotifier(false);

  void toggleShowSearch() => showSearch.value = !showSearch.value;

  final searchQuery = SafeValueNotifier<String?>(null);
  void setSearchQuery(String value) => searchQuery.value = value;

  final filter = SafeValueNotifier<PodcastEpisodeFilter>(
    PodcastEpisodeFilter.title,
  );
  void setFilter() {
    filter.value = switch (filter.value) {
      PodcastEpisodeFilter.title => PodcastEpisodeFilter.description,
      PodcastEpisodeFilter.description => PodcastEpisodeFilter.title,
    };
  }

  late final Command<PodcastUpdateCapsule?, Set<String>> updatesCommand =
      Command.createAsyncWithProgress((param, handle) async {
        final feedUrls = param?.feedUrls ?? _podcastService.podcastFeedUrls;

        if (_podcastService.podcastUpdates.isEmpty) {
          await _podcastService.loadPodcastUpdatesFromDb();
        }

        if (param?.type == PodcastUpdateCapsuleType.remove) {
          for (final url in feedUrls) {
            await _podcastService.removePodcastUpdate(url);
          }
          return _podcastService.podcastUpdates;
        }

        final updates = await _podcastService.checkForUpdates(
          feedUrls: feedUrls,
          updateProgress: handle.updateProgress,
        );
        for (final feedUrl in feedUrls) {
          if (updates.contains(feedUrl)) {
            await getEpisodesCommand(
              feedUrl,
              forceRefresh: true,
            ).runAsync((feedUrl: feedUrl, item: null));
          }
        }
        return updates;
      }, initialValue: _podcastService.podcastUpdates);

  // Note: passing the item makes it easier to
  // always have the correct image without needing to persist every item
  final _episodesCommands =
      <String, Command<({Item? item, String? feedUrl}), List<Audio>>>{};
  Command<({Item? item, String? feedUrl}), List<Audio>> getEpisodesCommand(
    String feedUrl, {
    bool forceRefresh = false,
  }) {
    if (forceRefresh) {
      _episodesCommands.remove(feedUrl);
    }

    return _episodesCommands.putIfAbsent(
      feedUrl,
      () => Command.createAsync(
        (param) => _podcastService
            .findEpisodes(item: param.item, feedUrl: param.feedUrl)
            .timeout(const Duration(seconds: 30)),
        initialValue: [],
      ),
    );
  }

  bool shouldRunCommand(String feedUrl) =>
      di<PodcastManager>().getEpisodesCommand(feedUrl).value.isEmpty;

  //
  // Podcasts
  //

  String? getSubscribedPodcastImage(String feedUrl) =>
      _podcastService.getSubscribedPodcastImage(feedUrl);
  String? getSubscribedPodcastName(String feedUrl) =>
      _podcastService.getSubscribedPodcastName(feedUrl);
  String? getSubscribedPodcastArtist(String feedUrl) =>
      _podcastService.getSubscribedPodcastArtist(feedUrl);

  bool isPodcastSubscribed(String? feedUrl) =>
      feedUrl == null ? false : togglePodcastCommand.value.contains(feedUrl);

  late final Command<PodcastToggleCapsule?, List<String>> togglePodcastCommand =
      Command.createAsync((param) async {
        if (_podcastService.podcastFeedUrls.isEmpty) {
          await _podcastService.loadPodcastCacheFromDb();
          await _podcastService.loadPodcastUpdatesFromDb();
        }

        if (param?.feedUrl != null) {
          if (_podcastService.podcastFeedUrls.contains(param!.feedUrl)) {
            await _podcastService.removePodcast(param.feedUrl);
          } else if (param.name != null && param.artist != null) {
            await _podcastService.addPodcast(
              feedUrl: param.feedUrl,
              imageUrl: param.imageUrl,
              name: param.name!,
              artist: param.artist!,
            );
          } else {
            throw ArgumentError('name and artist are required');
          }
        }

        return _podcastService.podcastFeedUrls;
      }, initialValue: _podcastService.podcastFeedUrls);

  late final Command<({String feedUrl, bool ascending}), Set<String>>
  reorderPodcastCommand = Command.createAsync((param) async {
    await _podcastService.reorderPodcast(
      feedUrl: param.feedUrl,
      ascending: param.ascending,
    );
    getEpisodesCommand(
      param.feedUrl,
      forceRefresh: true,
    ).run((feedUrl: param.feedUrl, item: null));

    return _podcastService.ascendingPodcasts;
  }, initialValue: _podcastService.ascendingPodcasts);

  Future<void> updateAudioDuration(Audio audio) =>
      _podcastService.updateAudioDuration(audio);

  late final Command<void, Set<String>> feedsWithDownloadsCommand =
      Command.createAsyncNoParam(() async {
        if (_podcastService.feedsWithDownloads.isEmpty) {
          await _podcastService.loadDownloadsFromDb();
        }

        return _podcastService.feedsWithDownloads;
      }, initialValue: _podcastService.feedsWithDownloads);

  final downloadCommands =
      MapNotifier<Audio, Command<void, PodcastDownloadResult?>>(
        notificationMode: CustomNotifierMode.manual,
      );

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

  late final Command<void, void> wipeCommand =
      Command.createAsyncNoParamNoResult(() async {
        await _podcastService.wipeAndBuildPodcastLibrary();
        _episodesCommands.clear();
        downloadCommands.clear();
        await togglePodcastCommand.runAsync();
        await feedsWithDownloadsCommand.runAsync();
      });

  final _downloadController =
      StreamController<PodcastDownloadResult>.broadcast();
  Stream<PodcastDownloadResult> get downloadStream =>
      _downloadController.stream;

  @disposeMethod
  Future<void> dispose() async {
    await _downloadController.close();
  }
}

enum PodcastEpisodeFilter {
  title,
  description;

  String localize(AppLocalizations l10n) => switch (this) {
    title => l10n.title,
    description => l10n.description,
  };
}

enum PodcastUpdateCapsuleType { remove, update }

class PodcastUpdateCapsule {
  final PodcastUpdateCapsuleType type;
  final List<String>? feedUrls;

  PodcastUpdateCapsule({required this.type, this.feedUrls});
}

class PodcastToggleCapsule {
  final String feedUrl;
  final String? imageUrl;
  final String? name;
  final String? artist;

  PodcastToggleCapsule({
    required this.feedUrl,
    this.imageUrl,
    this.name,
    this.artist,
  });
}

enum PodcastDownloadStatus { removed, downloaded, cancelled }

class PodcastDownloadResult {
  final PodcastDownloadStatus status;
  final Audio audio;
  final String? path;

  const PodcastDownloadResult({
    required this.status,
    required this.audio,
    required this.path,
  });
}
