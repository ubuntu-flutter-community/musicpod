import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/keep_alive_registry.dart';
import 'data/podcast_episode_filter.dart';
import 'data/podcast_short_info.dart';
import 'data/podcast_toggle_capsule.dart';
import 'data/podcast_update_capsule.dart';
import 'episodes_manager.dart';
import 'podcast_service.dart';

// Note: we need to see the subbed podcasts at the start
// thus we can't make this a lazy singleton or factory
@singleton
class PodcastManager {
  PodcastManager({required PodcastService podcastService})
    : _podcastService = podcastService {
    togglePodcastCommand.run();
    feedsWithDownloadsCommand.run();
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

  bool isPodcastSubscribed(String? feedUrl) =>
      feedUrl == null ? false : _podcastService.isPodcastSubscribed(feedUrl);
  Future<void> updateAudioDuration(Audio audio) =>
      _podcastService.updateAudioDuration(audio);

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
          await di<EpisodesManager>(param1: feedUrl).command.runAsync();
        }

        return updates;
      }, initialValue: _podcastService.podcastUpdates);

  late final Command<PodcastToggleCapsule?, List<String>> togglePodcastCommand =
      Command.createAsync((param) async {
        if (_podcastService.podcastFeedUrls.isEmpty) {
          await _podcastService.loadPodcasts();
          await _podcastService.loadPodcastUpdates();
        }

        if (param?.feedUrl != null) {
          if (_podcastService.podcastFeedUrls.contains(param!.feedUrl)) {
            await _podcastService.removePodcastsWithUpdatesAndEpisodes(
              param.feedUrl,
            );
            PodcastShortInfoManager.dispose(param.feedUrl);
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

    return _podcastService.ascendingPodcasts;
  }, initialValue: {});

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
        await togglePodcastCommand.runAsync();
        await feedsWithDownloadsCommand.runAsync();
      });
}

@Injectable(cache: true)
class PodcastImageManager {
  PodcastImageManager({
    @factoryMethod required String feedUrl,
    required PodcastService podcastService,
  }) {
    command = Command.createAsync(
      podcastService.getSubscribedPodcastImage,
      initialValue: null,
    );

    command.run(feedUrl);
  }

  late final Command<String, String?> command;
}

@Injectable(cache: true)
class PodcastNameManager {
  PodcastNameManager({
    @factoryMethod required String feedUrl,
    required PodcastService podcastService,
  }) {
    command = Command.createAsync(
      podcastService.getPodcastName,
      initialValue: null,
    );
    command.run(feedUrl);
  }

  late final Command<String, String?> command;
}

@injectable
class PodcastShortInfoManager {
  PodcastShortInfoManager._({
    required String feedUrl,
    required PodcastService podcastService,
  }) {
    command = Command.createAsync(
      podcastService.getPodcastShortInfo,
      initialValue: null,
    );

    command.run(feedUrl);
  }

  @factoryMethod
  static PodcastShortInfoManager create({
    @factoryParam required String feedUrl,
    required PodcastService podcastService,
  }) => _registry.getOrRegister(
    id: feedUrl,
    factoryFunction: () => PodcastShortInfoManager._(
      feedUrl: feedUrl,
      podcastService: podcastService,
    ),
  );

  static final _registry = KeepAliveRegistry<String, PodcastShortInfoManager>();
  static PodcastShortInfoManager? dispose(String feedUrl) =>
      _registry.dispose(feedUrl);

  late final Command<String, PodcastShortInfo?> command;
}
