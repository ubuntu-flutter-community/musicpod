import 'dart:async';

import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../l10n/app_localizations.dart';
import 'podcast_service.dart';

class PodcastModel extends SafeChangeNotifier {
  PodcastModel({required PodcastService podcastService})
    : _podcastService = podcastService;

  final PodcastService _podcastService;

  Future<void> init({
    required String updateMessage,
    bool forceInit = false,
    Function({required String message})? notify,
  }) async {
    await _podcastService.init(forceInit: forceInit);
    notifyListeners();
  }

  void update({
    String? updateMessage,
    // Note: because the podcasts can be modified to include downloads
    // this needs a map and not only the feedurl
    Map<String, List<Audio>>? oldPodcasts,
  }) {
    _setCheckingForUpdates(true);
    _podcastService
        .updatePodcasts(updateMessage: updateMessage, oldPodcasts: oldPodcasts)
        .then((_) => _setCheckingForUpdates(false));
  }

  bool _checkingForUpdates = false;
  bool get checkingForUpdates => _checkingForUpdates;
  void _setCheckingForUpdates(bool value) {
    if (_checkingForUpdates == value) return;
    _checkingForUpdates = value;
    notifyListeners();
  }

  bool _updatesOnly = false;
  bool get updatesOnly => _updatesOnly;
  void setUpdatesOnly(bool value) {
    if (_updatesOnly == value) return;
    _updatesOnly = value;
    notifyListeners();
  }

  bool _downloadsOnly = false;
  bool get downloadsOnly => _downloadsOnly;
  void setDownloadsOnly(bool value) {
    if (_downloadsOnly == value) return;
    _downloadsOnly = value;
    notifyListeners();
  }

  final Map<String, bool> _showSearch = {};

  void toggleShowSearch({required String feedUrl}) {
    _showSearch[feedUrl] = !(_showSearch[feedUrl] ?? false);
    if (_showSearch[feedUrl] != true) {
      _searchQuery[feedUrl] = null;
    }
    notifyListeners();
  }

  bool getShowSearch(String? feedUrl) =>
      feedUrl == null ? false : _showSearch[feedUrl] ?? false;

  final Map<String, String?> _searchQuery = {};
  void setSearchQuery({required String feedUrl, required String value}) {
    if (value == _searchQuery[feedUrl]) return;
    _searchQuery[feedUrl] = value;
    notifyListeners();
  }

  PodcastEpisodeFilter _filter = PodcastEpisodeFilter.title;
  PodcastEpisodeFilter get filter => _filter;
  void setFilter() {
    _filter = switch (_filter) {
      PodcastEpisodeFilter.title => PodcastEpisodeFilter.description,
      PodcastEpisodeFilter.description => PodcastEpisodeFilter.title,
    };
    notifyListeners();
  }

  set filter(PodcastEpisodeFilter value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  String? getSearchQuery(String? feedUrl) => _searchQuery[feedUrl];

  Future<List<Audio>> findEpisodes({Item? item, String? feedUrl}) =>
      _podcastService.findEpisodes(item: item, feedUrl: feedUrl);
}

enum PodcastEpisodeFilter {
  title,
  description;

  String localize(AppLocalizations l10n) => switch (this) {
    title => l10n.title,
    description => l10n.description,
  };
}
