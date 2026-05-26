import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
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
        for (final feedUrl
            in (capsule.feedUrls.isEmpty
                ? _podcastService.podcastFeedUrls
                : capsule.feedUrls)) {
          await getEpisodesCommand(
            feedUrl,
            clearCache: true,
            loadFresh: true,
          ).runAsync((feedUrl: feedUrl, item: null));
        }
        return updates;
      }, initialValue: _podcastService.podcastUpdates);

  // Note: passing the item makes it easier to
  // always have the correct image without needing to persist every item
  final _episodesCommands =
      <String, Command<({Item? item, String? feedUrl}), List<Audio>>>{};
  Command<({Item? item, String? feedUrl}), List<Audio>> getEpisodesCommand(
    String feedUrl, {
    bool clearCache = false,
    bool loadFresh = false,
  }) {
    if (clearCache) {
      _episodesCommands.remove(feedUrl);
    }

    return _episodesCommands.putIfAbsent(
      feedUrl,
      () => Command.createAsync(
        (param) => _podcastService
            .findEpisodes(
              item: param.item,
              feedUrl: param.feedUrl,
              loadFresh: loadFresh,
            )
            .timeout(const Duration(seconds: 30)),
        initialValue: [],
      ),
    );
  }

  final cooldown = SafeValueNotifier<int>(_cooldownMaxSeconds);
  Timer? _cooldownTimer;
  void maybeRunEpisodesCommand({
    required String feedUrl,
    Item? podcastItem,
    bool clearErrors = false,
  }) {
    final command = getEpisodesCommand(feedUrl);

    if (clearErrors) {
      command.clearErrors();
    }

    if (command.value.isEmpty && command.errors.value == null) {
      command.run((feedUrl: feedUrl, item: podcastItem));
      return;
    }

    if (command.errors.value != null && _cooldownTimer == null) {
      cooldown.value = _cooldownMaxSeconds;

      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (cooldown.value > 0) {
          cooldown.value--;
        } else {
          _cooldownTimer?.cancel();
          _cooldownTimer = null;
          command.clearErrors();
          maybeRunEpisodesCommand(
            feedUrl: feedUrl,
            podcastItem: podcastItem,
            clearErrors: true,
          );
        }
      });
    }
  }

  late final Command<({String feedUrl, String name}), String?> cleanUpCommand =
      Command.createAsync((param) async {
        if (_podcastService.isPodcastSubscribed(param.feedUrl)) return null;

        await _podcastService.removePodcast(param.feedUrl);
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
      clearCache: true,
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

  late final Command<void, void> wipeCommand =
      Command.createAsyncNoParamNoResult(() async {
        await _podcastService.wipeAndBuildPodcastLibrary();
        _episodesCommands.clear();
        await togglePodcastCommand.runAsync();
        await feedsWithDownloadsCommand.runAsync();
      });
}

const _cooldownMaxSeconds = 20;
