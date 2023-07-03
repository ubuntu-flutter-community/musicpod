import 'dart:async';

import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/data/podcast_genre.dart';
import 'package:musicpod/utils.dart';
import 'package:podcast_search/podcast_search.dart';

class PodcastService {
  PodcastService() : _search = Search();

  final _chartsChangedController = StreamController<bool>.broadcast();
  Stream<bool> get chartsChanged => _chartsChangedController.stream;
  Set<Set<Audio>>? _chartsPodcasts;
  Set<Set<Audio>>? get chartsPodcasts => _chartsPodcasts;
  final Search _search;

  static Future<Podcast?> loadPodcast(String url) async {
    try {
      return await Podcast.loadFeed(
        url: url,
      );
    } catch (e) {
      return null;
    }
  }

  void loadCharts({
    PodcastGenre podcastGenre = PodcastGenre.all,
    Country? country,
  }) async {
    _chartsPodcasts = null;
    _chartsChangedController.add(true);

    SearchResult chartsSearch = await _search.charts(
      genre: podcastGenre == PodcastGenre.all ? '' : podcastGenre.id,
      limit: 10,
      country: country ?? Country.none,
    );

    if (chartsSearch.successful && chartsSearch.items.isNotEmpty) {
      _chartsPodcasts ??= {};
      _chartsPodcasts?.clear();

      for (final item in chartsSearch.items) {
        if (item.feedUrl != null) {
          try {
            final Podcast? podcast = await compute(loadPodcast, item.feedUrl!);

            if (podcast?.episodes.isNotEmpty == true) {
              final chartsPodcast = podcast!.episodes
                  .map((e) => _createAudio(e, podcast, item))
                  .toSet();

              _chartsPodcasts?.add(chartsPodcast);
              _chartsChangedController.add(true);
            }
            _chartsChangedController.add(true);
          } on PodcastFailedException {
            _chartsChangedController.add(true);
          }
        }
      }
    } else {
      _chartsPodcasts = {};
      _chartsChangedController.add(true);
    }
  }

  final _searchChangedController = StreamController<bool>.broadcast();
  Stream<bool> get searchChanged => _searchChangedController.stream;
  Set<Set<Audio>>? _searchResult;
  Set<Set<Audio>>? get searchResult => _searchResult;

  void _updateSearchResult(Set<Set<Audio>>? value) {
    _searchResult = value;
    _searchChangedController.add(true);
  }

  Future<void> search({
    String? searchQuery,
    PodcastGenre podcastGenre = PodcastGenre.science,
    Country? country,
    Language language = Language.none,
  }) async {
    if (searchQuery == null || searchQuery.isEmpty == true) return;
    _updateSearchResult(null);

    SearchResult results = await _search.search(
      searchQuery,
      country: country ?? Country.none,
      language: language,
      limit: 10,
    );

    if (results.successful && results.items.isNotEmpty) {
      _searchResult ??= {};
      _searchResult?.clear();

      for (var item in results.items) {
        if (item.feedUrl != null) {
          try {
            final Podcast? podcast = await compute(loadPodcast, item.feedUrl!);

            if (podcast?.episodes.isNotEmpty == true) {
              final episodes = <Audio>{};

              for (var episode in podcast?.episodes ?? <Episode>[]) {
                if (episode.contentUrl != null) {
                  final audio = _createAudio(episode, podcast, item);

                  episodes.add(audio);
                }
              }
              _searchResult?.add(episodes);
              _searchChangedController.add(true);
            }
          } on PodcastFailedException {
            _searchChangedController.add(true);
          }
        }
      }
    } else {
      _updateSearchResult({});
    }
  }

  Audio _createAudio(Episode episode, Podcast? podcast, Item item) {
    return Audio(
      url: episode.contentUrl,
      audioType: AudioType.podcast,
      imageUrl: episode.imageUrl,
      albumArtUrl: podcast?.image,
      title: episode.title,
      album: item.collectionName,
      artist: item.artistName,
      description: podcast?.description,
      website: podcast?.url,
    );
  }

  Future<Set<Audio>> findEpisodes({required String url}) async {
    final episodes = <Audio>{};
    final Podcast? podcast = await compute(loadPodcast, url);

    if (podcast?.episodes.isNotEmpty == true) {
      for (var episode in podcast?.episodes ?? []) {
        if (episode.contentUrl != null) {
          final audio = Audio(
            url: episode.contentUrl,
            audioType: AudioType.podcast,
            imageUrl: podcast?.image ?? episode.imageUrl,
            title: episode.title,
            album: podcast?.title,
            artist: podcast?.copyright,
            description: podcast?.description,
            website: podcast?.url,
          );
          episodes.add(audio);
        }
      }
    }
    return episodes;
  }

  bool? _checkedForUpdates;
  Future<void> updatePodcasts({
    required Map<String, Set<Audio>> oldPodcasts,
    required void Function(String name, Set<Audio> audios) updatePodcast,
    required String updateMessage,
    required Future<Notification> Function(
      String summary, {
      String body,
      String appName,
      String appIcon,
      int expireTimeoutMs,
      int replacesId,
      List<NotificationHint> hints,
      List<NotificationAction> actions,
    }) notify,
  }) async {
    if (_checkedForUpdates == true) return;
    for (final oldPodcast in oldPodcasts.entries) {
      if (oldPodcast.value.firstOrNull?.website != null) {
        findEpisodes(
          url: oldPodcast.value.firstOrNull!.website!,
        ).then((audios) {
          if (!listsAreEqual(
            audios.toList(),
            oldPodcast.value.toList(),
          )) {
            updatePodcast(oldPodcast.key, audios);
            notify(
              'New episodes available: ${oldPodcast.key}',
              appIcon: 'music-app',
              appName: 'MusicPod',
            );
          }
        });
      }
    }
    _checkedForUpdates = true;
  }
}
