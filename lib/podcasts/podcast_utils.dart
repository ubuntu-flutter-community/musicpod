import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/common_widgets.dart';
import '../../common/view/icons.dart';
import '../common/data/audio.dart';
import '../common/view/audio_filter.dart';
import '../l10n/l10n.dart';
import '../library/library_model.dart';
import '../player/player_model.dart';
import 'podcast_model.dart';
import 'view/podcast_page.dart';

Future<void> searchAndPushPodcastPage({
  required BuildContext context,
  required String? feedUrl,
  String? itemImageUrl,
  String? genre,
  required bool play,
}) async {
  ScaffoldMessenger.of(context).clearSnackBars();

  final libraryModel = di<LibraryModel>();
  if (feedUrl != null && libraryModel.isPageInLibrary(feedUrl)) {
    return libraryModel.pushNamed(feedUrl);
  }

  if (feedUrl == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.podcastFeedIsEmpty),
      ),
    );
    return;
  }
  final model = di<PodcastModel>();
  final startPlaylist = di<PlayerModel>().startPlaylist;
  final selectedFeedUrl = model.selectedFeedUrl;
  final setSelectedFeedUrl = model.setSelectedFeedUrl;

  setSelectedFeedUrl(feedUrl);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 20),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(context.l10n.loadingPodcastFeed),
          SizedBox(
            height: iconSize,
            width: iconSize,
            child: const Progress(),
          ),
        ],
      ),
    ),
  );

  return findEpisodes(
    feedUrl: feedUrl,
    itemImageUrl: itemImageUrl,
    genre: genre,
  ).then((podcast) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (selectedFeedUrl == feedUrl) {
      return;
    }
    if (podcast.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.podcastFeedIsEmpty),
        ),
      );
      return;
    }

    if (play) {
      startPlaylist.call(listName: feedUrl, audios: podcast).then(
            (_) => setSelectedFeedUrl(null),
          );
    } else {
      di<LibraryModel>()
          .push(
        builder: (_) {
          return PodcastPage(
            imageUrl: itemImageUrl ?? podcast.firstOrNull?.imageUrl,
            audios: podcast,
            pageId: feedUrl,
            title: podcast.firstOrNull?.album ??
                podcast.firstOrNull?.title ??
                feedUrl,
          );
        },
        pageId: feedUrl,
      )
          .then((_) {
        setSelectedFeedUrl(null);
      });
    }
  });
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
        final audio = Audio.fromPodcast(
          episode: episode,
          podcast: podcast,
          itemImageUrl: itemImageUrl,
          genre: genre,
        );
        episodes.add(audio);
      }
    }
  }
  final sortedEpisodes = episodes.toList();
  sortListByAudioFilter(
    audioFilter: AudioFilter.year,
    audios: sortedEpisodes,
    descending: true,
  );
  return Set<Audio>.from(sortedEpisodes);
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
