import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../common/data/audio.dart';
import '../data/podcast_episode_filter.dart';
import '../data/podcast_short_info.dart';
import '../service/podcast_service.dart';
import 'podcast_genre_manager.dart';

@lazySingleton
class PodcastManager {
  PodcastManager({required PodcastService podcastService})
    : _podcastService = podcastService;

  final PodcastService _podcastService;

  late final Command<({SearchProvider searchProvider}), void>
  initSearchCommand = Command.createSyncNoResult((param) async {
    _podcastService.initSearchProvider(param.searchProvider);
    await di<PodcastLoadGenresManager>().command.runAsync((force: true));
  });

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
  void setFilter() => filter.value = switch (filter.value) {
    PodcastEpisodeFilter.title => PodcastEpisodeFilter.description,
    PodcastEpisodeFilter.description => PodcastEpisodeFilter.title,
  };

  Future<void> updateAudioDuration(Audio audio) =>
      _podcastService.updateAudioDuration(audio);

  // TODO: when the downloads/updates filters are moved to the episode loading
  // we can move this command to its own manager
  late final Command<void, void> wipeCommand =
      Command.createAsyncNoParamNoResult(
        _podcastService.wipeAndBuildPodcastLibrary,
      );

  Future<void> togglePodcastSubscription({required String feedUrl}) =>
      _podcastService.togglePodcastSubscription(feedUrl: feedUrl);

  Future<Set<String>> getSubscribedPodcasts() =>
      _podcastService.getSubscribedPodcasts();

  Future<void> loadDownloads() => _podcastService.loadDownloads();

  Set<String> get feedsWithDownloads => _podcastService.feedsWithDownloads;

  Future<PodcastShortInfo?> getPodcastShortInfo(String feedUrl) =>
      _podcastService.getPodcastShortInfo(feedUrl);
}
