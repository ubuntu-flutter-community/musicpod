import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../l10n/app_localizations.dart';
import 'podcast_service.dart';

@lazySingleton
class PodcastManager extends SafeChangeNotifier {
  PodcastManager({required PodcastService podcastService})
    : _podcastService = podcastService {
    _propertiesChangedSub = _podcastService.propertiesChanged.listen(
      (_) => notifyListeners(),
    );
  }

  final PodcastService _podcastService;
  StreamSubscription<bool>? _propertiesChangedSub;

  @disposeMethod
  @override
  Future<void> dispose() async {
    await _propertiesChangedSub?.cancel();
    super.dispose();
  }

  late final Command<({bool forceInit}), void> initSearchCommand =
      Command.createSyncNoResult(
        (param) => _podcastService.init(forceInit: param.forceInit),
      );

  Future<void> checkForUpdates({
    required String updateMessage,
    required String Function(int length) multiUpdateMessage,
    // Note: because the podcasts can be modified to include downloads
    // this needs a map and not only the feedurl
    Set<String>? feedUrls,
  }) async => _podcastService.checkForUpdates(
    updateMessage: updateMessage,
    multiUpdateMessage: multiUpdateMessage,
    feedUrls: feedUrls,
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

  late final Command<String, void> checkForUpdateAndRefreshIfNeededCommand =
      Command.createAsyncNoResult((feedUrl) async {
        final updates = await _podcastService.checkForUpdates(
          feedUrls: {feedUrl},
          updateMessage: '',
          multiUpdateMessage: (length) => '',
        );
        if (updates.contains(feedUrl)) {
          await getEpisodesCommand(
            feedUrl,
            forceRefresh: true,
          ).runAsync((feedUrl: feedUrl, item: null));
        }
      });

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

  List<String> get podcastFeedUrls => _podcastService.podcastFeedUrls;
  int get podcastsLength => _podcastService.podcastsLength;
  Future<void> addPodcast({
    required String feedUrl,
    String? imageUrl,
    required String name,
    required String artist,
  }) async => _podcastService.addPodcast(
    feedUrl: feedUrl,
    imageUrl: imageUrl,
    name: name,
    artist: artist,
  );
  String? getSubscribedPodcastImage(String feedUrl) =>
      _podcastService.getSubscribedPodcastImage(feedUrl);
  void addSubscribedPodcastImage({
    required String feedUrl,
    required String imageUrl,
  }) => _podcastService.addSubscribedPodcastImage(
    feedUrl: feedUrl,
    imageUrl: imageUrl,
  );
  String? getSubscribedPodcastName(String feedUrl) =>
      _podcastService.getSubscribedPodcastName(feedUrl);
  String? getSubscribedPodcastArtist(String feedUrl) =>
      _podcastService.getSubscribedPodcastArtist(feedUrl);
  void removePodcast(String feedUrl) => _podcastService.removePodcast(feedUrl);

  bool isPodcastSubscribed(String? feedUrl) =>
      feedUrl == null ? false : _podcastService.isPodcastSubscribed(feedUrl);
  bool podcastUpdateAvailable(String feedUrl) =>
      _podcastService.podcastUpdateAvailable(feedUrl);
  int? get podcastUpdatesLength => _podcastService.podcastUpdatesLength;
  Future<void> removePodcastUpdate(String feedUrl) async =>
      _podcastService.removePodcastUpdate(feedUrl);

  int get downloadsLength => _podcastService.downloads.length;
  String? getDownload(String? url) =>
      url == null ? null : _podcastService.downloads[url];
  bool feedHasDownload(String? feedUrl) =>
      feedUrl == null ? false : _podcastService.feedHasDownloads(feedUrl);
  int get feedsWithDownloadsLength => _podcastService.feedsWithDownloadsLength;

  Future<void> reorderPodcast({
    required String feedUrl,
    required bool ascending,
  }) => _podcastService.reorderPodcast(feedUrl: feedUrl, ascending: ascending);

  bool showPodcastAscending(String feedUrl) =>
      _podcastService.showPodcastAscending(feedUrl);

  Future<void> removeAllPodcasts() async => _podcastService.removeAllPodcasts();
}

enum PodcastEpisodeFilter {
  title,
  description;

  String localize(AppLocalizations l10n) => switch (this) {
    title => l10n.title,
    description => l10n.description,
  };
}
