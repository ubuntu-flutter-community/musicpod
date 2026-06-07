import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/logging.dart';
import 'data/find_episodes_param.dart';
import 'data/podcast_episode_filter.dart';
import 'data/podcast_toggle_capsule.dart';
import 'data/podcast_update_capsule.dart';
import 'podcast_service.dart';

// Note: we need to see the subbed podcasts at the start
// thus we can't make this a lazy singleton or factory
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

  late final Command<PodcastUpdateCapsule, Set<String>> manageUpdatesCommand =
      Command.createAsyncWithProgress((capsule, handle) async {
        if (capsule.type == PodcastUpdateType.remove) {
          await _podcastService.removePodcastUpdates(
            feedUrls: capsule.feedUrls,
            updateProgress: handle.updateProgress,
          );
          return _podcastService.podcastUpdates;
        }

        final updates = await _podcastService.checkForUpdates(
          feedUrls: capsule.feedUrls,
          updateProgress: handle.updateProgress,
        );
        for (final feedUrl in updates) {
          await getEpisodesCommand(feedUrl).runAsync(
            FindEpisodesParam(
              feedUrl: feedUrl,
              item: null,
              tryFromDbOnly: true,
            ),
          );
        }
        return updates;
      }, initialValue: _podcastService.podcastUpdates);

  // Note: passing the item makes it easier to
  // always have the correct image without needing to persist every item
  final _episodesCommands =
      <String, Command<FindEpisodesParam, List<Audio>?>>{};
  Command<FindEpisodesParam, List<Audio>?> getEpisodesCommand(String feedUrl) =>
      _episodesCommands.putIfAbsent(
        feedUrl,
        () => Command.createAsync(
          (param) => _podcastService
              .findEpisodes(
                item: param.item,
                feedUrl: param.feedUrl,
                tryFromDbOnly: param.tryFromDbOnly,
              )
              .timeout(
                FindEpisodesTimeoutException.timeoutDuration,
                onTimeout: () {
                  throw FindEpisodesTimeoutException();
                },
              ),
          initialValue: null,
        ),
      );

  late final Command<void, Set<String>?>
  cleanUpAllUnSubbedCommand = Command.createAsyncNoParam(() async {
    final unsubbedFeedUrls = _episodesCommands.keys
        .where((feedUrl) => !_podcastService.podcastFeedUrls.contains(feedUrl))
        .toSet();

    if (unsubbedFeedUrls.isEmpty) {
      return null;
    }

    printMessageInDebugMode(
      'Trying to clean unsubbed feed urls: $unsubbedFeedUrls ...',
    );

    final toCleanUpNames = <String>{};
    for (final feedUrl in unsubbedFeedUrls) {
      toCleanUpNames.add(
        _episodesCommands[feedUrl]?.value?.firstOrNull?.podcastTitle ?? feedUrl,
      );
    }

    await _podcastService.cleanPodcasts(toCleanUpNames.toList());
    _episodesCommands.removeWhere((key, _) => unsubbedFeedUrls.contains(key));

    return toCleanUpNames;
  }, initialValue: null);

  late final Command<({String feedUrl, String name}), String?> cleanUpCommand =
      Command.createAsync((param) async {
        if (_podcastService.isPodcastSubscribed(param.feedUrl)) return null;

        await _podcastService.cleanPodcasts([param.feedUrl]);
        _episodesCommands.remove(param.feedUrl);
        return param.name;
      }, initialValue: null);

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
          await _podcastService.loadPodcasts();
          await _podcastService.loadPodcastUpdates();
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
    getEpisodesCommand(param.feedUrl).run(
      FindEpisodesParam(
        feedUrl: param.feedUrl,
        item: null,
        tryFromDbOnly: true,
      ),
    );

    return _podcastService.ascendingPodcasts;
  }, initialValue: _podcastService.ascendingPodcasts);

  Future<void> updateAudioDuration(Audio audio) =>
      _podcastService.updateAudioDuration(audio);

  late final Command<void, Set<String>> feedsWithDownloadsCommand =
      Command.createAsyncNoParam(() async {
        if (_podcastService.feedsWithDownloads.isEmpty) {
          await _podcastService.loadDownloads();
        }

        return _podcastService.feedsWithDownloads;
      }, initialValue: _podcastService.feedsWithDownloads);

  late final Command<void, void> wipeCommand =
      Command.createAsyncNoParamNoResult(() async {
        await _podcastService.wipeAndBuildPodcastLibrary();
        _episodesCommands.clear();
        await togglePodcastCommand.runAsync();
        await feedsWithDownloadsCommand.runAsync();
      });
}
