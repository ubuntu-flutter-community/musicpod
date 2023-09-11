import 'dart:async';

import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/data/podcast_genre.dart';
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
    for (final old in oldPodcasts.entries) {
      final firstOld = old.value.firstOrNull;
      final podcast = firstOld?.album;
      if (podcast == null || podcast.isEmpty) break;

      if (firstOld?.website != null) {
        await findEpisodes(
          feedUrl: firstOld!.website!,
        ).then((audios) {
          if (firstOld.year != null &&
                  audios.firstOrNull?.year == firstOld.year ||
              audios.isEmpty) return;

          updatePodcast(old.key, audios);
          notify(
            '$updateMessage ${firstOld.album ?? old.value}',
            appIcon: 'music-app',
            appName: 'MusicPod',
          );
        });
      }
    }
  }
}

Audio _createAudio(
  Episode episode,
  Podcast? podcast, [
  String? itemImageUrl,
  String? genre,
]) {
  return Audio(
    url: episode.contentUrl,
    audioType: AudioType.podcast,
    imageUrl: episode.imageUrl,
    albumArtUrl: itemImageUrl ?? podcast?.image,
    title: episode.title,
    album: podcast?.title,
    artist: podcast?.copyright,
    albumArtist: podcast?.description,
    durationMs: episode.duration?.inMilliseconds.toDouble(),
    year: episode.publicationDate?.millisecondsSinceEpoch,
    description: episode.description,
    website: podcast?.url,
    genre: genre,
  );
}

Future<Set<Audio>> findEpisodes({
  required String feedUrl,
  String? itemImageUrl,
  String? genre,
}) async {
  final episodes = <Audio>{};
  final Podcast? podcast = await compute(loadPodcast, feedUrl);

  if (podcast?.episodes.isNotEmpty == true) {
    for (var episode in podcast?.episodes ?? []) {
      if (episode.contentUrl != null) {
        final audio = _createAudio(
          episode,
          podcast,
          itemImageUrl,
          genre,
        );
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
