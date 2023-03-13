import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/data/podcast_genre.dart';
import 'package:podcast_search/podcast_search.dart';

class PodcastService {
  final _chartsChangedController = StreamController<bool>.broadcast();
  Stream<bool> get chartsChanged => _chartsChangedController.stream;
  Set<Set<Audio>>? _chartsPodcasts;
  Set<Set<Audio>>? get chartsPodcasts => _chartsPodcasts;

  static Future<Podcast> loadPodcast(String url) async =>
      await Podcast.loadFeed(
        url: url,
      );

  void loadCharts({
    PodcastGenre podcastGenre = PodcastGenre.science,
    Country country = Country.UNITED_KINGDOM,
  }) {
    Search()
        .charts(
      genre: podcastGenre.id,
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

            for (var episode in podcast.episodes ?? <Episode>[]) {
              final audio = Audio(
                url: episode.contentUrl,
                audioType: AudioType.podcast,
                name: podcast.title,
                imageUrl: podcast.image,
                metadata: Metadata(
                  title: episode.title,
                  album: item.collectionName,
                  artist: item.artistName,
                ),
                description: podcast.description,
                website: podcast.url,
              );

              episodes.add(audio);
            }
            chartsPodcasts?.add(episodes);
            _chartsChangedController.add(true);
          }
        }
      } else {
        _chartsPodcasts = null;
        _chartsChangedController.add(true);
      }
    });
  }
}
