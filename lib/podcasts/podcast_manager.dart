import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../l10n/app_localizations.dart';
import 'podcast_service.dart';

@lazySingleton
class PodcastManager {
  PodcastManager({required PodcastService podcastService})
    : _podcastService = podcastService;

  final PodcastService _podcastService;

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

  // Note: passing the item makes it easier to
  // always have the correct image without needing to persist every item
  final _episodesCommands =
      <String, Command<({Item? item, String? feedUrl}), List<Audio>>>{};
  Command<({Item? item, String? feedUrl}), List<Audio>> getEpisodesCommand(
    String feedUrl,
  ) => _episodesCommands.putIfAbsent(
    feedUrl,
    () => Command.createAsync(
      (param) => _podcastService
          .findEpisodes(item: param.item, feedUrl: param.feedUrl)
          .timeout(const Duration(seconds: 30)),
      initialValue: [],
    ),
  );

  bool shouldRunCommand(String feedUrl) =>
      di<PodcastManager>().getEpisodesCommand(feedUrl).value.isEmpty;
}

enum PodcastEpisodeFilter {
  title,
  description;

  String localize(AppLocalizations l10n) => switch (this) {
    title => l10n.title,
    description => l10n.description,
  };
}
