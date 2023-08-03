import 'dart:async';

import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/data/podcast_genre.dart';
import 'package:musicpod/utils.dart';
import 'package:podcast_search/podcast_search.dart';

class PodcastService {
  PodcastService() : _search = Search();

  final _searchChangedController = StreamController<bool>.broadcast();
  Stream<bool> get searchChanged => _searchChangedController.stream;
  SearchResult? _searchResult;
  SearchResult? get searchResult => _searchResult;
  final Search _search;

  Future<void> dispose() async {
    _searchChangedController.close();
  }

  Future<void> search({
    String? searchQuery,
    PodcastGenre podcastGenre = PodcastGenre.science,
    Country? country,
    int limit = 10,
  }) async {
    _searchResult = null;

    SearchResult? result;
    String? error;
    try {
      if (searchQuery == null || searchQuery.isEmpty == true) {
        result = await _search.charts(
          genre: podcastGenre == PodcastGenre.all ? '' : podcastGenre.id,
          limit: limit,
          country: country ?? Country.none,
        );
      } else {
        result = await _search.search(
          searchQuery,
          country: country ?? Country.none,
          language: Language.none,
          limit: limit,
        );
      }
    } catch (e) {
      error = e.toString();
    }

    if (result != null && result.successful) {
      _searchResult = result;
    } else {
      _searchResult =
          SearchResult.fromError(lastError: error ?? 'Something went wrong');
    }
    _searchChangedController.add(true);
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

Audio _createAudio(Episode episode, Podcast? podcast) {
  return Audio(
    url: episode.contentUrl,
    audioType: AudioType.podcast,
    imageUrl: episode.imageUrl,
    albumArtUrl: podcast?.image,
    title: episode.title,
    album: podcast?.title,
    artist: podcast?.copyright,
    albumArtist: podcast?.description,
    durationMs: episode.duration?.inMilliseconds.toDouble(),
    year: episode.publicationDate?.millisecondsSinceEpoch,
    description: episode.description,
    website: podcast?.url,
  );
}

Future<Set<Audio>> findEpisodes({required String url}) async {
  final episodes = <Audio>{};
  final Podcast? podcast = await compute(loadPodcast, url);

  if (podcast?.episodes.isNotEmpty == true) {
    for (var episode in podcast?.episodes ?? []) {
      if (episode.contentUrl != null) {
        final audio = _createAudio(episode, podcast);
        episodes.add(audio);
      }
    }
  }
  return episodes;
}

Future<Podcast?> loadPodcast(String url) async {
  try {
    return await Podcast.loadFeed(
      url: url,
    );
  } catch (e) {
    return null;
  }
}
