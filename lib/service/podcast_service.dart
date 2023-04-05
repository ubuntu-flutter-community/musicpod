import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/data/podcast_genre.dart';
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
    Country country = Country.UNITED_KINGDOM,
  }) {
    _search
        .charts(
      genre: podcastGenre == PodcastGenre.all ? '' : podcastGenre.id,
      limit: 10,
      country: country,
    )
        .then((chartsSearch) async {
      if (chartsSearch.successful && chartsSearch.items.isNotEmpty) {
        _chartsPodcasts ??= {};
        chartsPodcasts?.clear();

        for (var item in chartsSearch.items) {
          if (item.feedUrl != null) {
            final podcast = await compute(loadPodcast, item.feedUrl!);
            final episodes = <Audio>{};

            for (var episode in podcast?.episodes ?? <Episode>[]) {
              final audio = Audio(
                url: episode.contentUrl,
                audioType: AudioType.podcast,
                imageUrl: podcast?.image,
                title: episode.title,
                album: item.collectionName,
                artist: item.artistName,
                description: podcast?.description,
                website: podcast?.url,
              );

              episodes.add(audio);
            }
            chartsPodcasts?.add(episodes);
            _chartsChangedController.add(true);
          }
        }
      } else {
        _chartsPodcasts = {};
        _chartsChangedController.add(true);
      }
    });
  }

  final _searchChangedController = StreamController<bool>.broadcast();
  Stream<bool> get searchChanged => _chartsChangedController.stream;
  Set<Set<Audio>>? _searchResult;
  Set<Set<Audio>>? get searchResult => _searchResult;

  void _updateSearchResult(Set<Set<Audio>>? value) {
    _searchResult = value;
    _searchChangedController.add(true);
  }

  Future<void> search({
    String? searchQuery,
    bool useAlbumImage = false,
    PodcastGenre podcastGenre = PodcastGenre.science,
    Country country = Country.UNITED_KINGDOM,
    Language language = Language.NONE,
  }) async {
    if (searchQuery?.isEmpty == true) return;
    _updateSearchResult(null);

    SearchResult results = await _search.search(
      searchQuery!,
      country: country,
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

            if (podcast?.episodes?.isNotEmpty == true) {
              final episodes = <Audio>{};

              for (var episode in podcast?.episodes ?? []) {
                if (episode.contentUrl != null) {
                  final audio = Audio(
                    url: episode.contentUrl,
                    audioType: AudioType.podcast,
                    imageUrl: useAlbumImage
                        ? podcast?.image ?? episode.imageUrl
                        : episode.imageUrl ?? podcast?.image,
                    title: episode.title,
                    album: podcast?.title,
                    artist: podcast?.copyright,
                    description: podcast?.description,
                    website: item.feedUrl,
                  );

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

  Future<Set<Audio>> findEpisodes({required String url}) async {
    final episodes = <Audio>{};
    final Podcast? podcast = await compute(loadPodcast, url);

    if (podcast?.episodes?.isNotEmpty == true) {
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
}
