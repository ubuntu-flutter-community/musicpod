import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../podcasts.dart';
import '../../l10n.dart';

class PodcastsDiscoverGrid extends StatelessWidget {
  const PodcastsDiscoverGrid({
    super.key,
    required this.searchResult,
    required this.startPlaylist,
    required this.podcastSubscribed,
    required this.removePodcast,
    required this.addPodcast,
    required this.setSelectedFeedUrl,
    required this.selectedFeedUrl,
    required this.onTapText,
  });

  final SearchResult searchResult;
  final Future<void> Function(Set<Audio> audios, String listName) startPlaylist;
  final bool Function(String? feedUrl) podcastSubscribed;
  final void Function(String feedUrl) removePodcast;
  final void Function(String feedUrl, Set<Audio> audios) addPodcast;
  final void Function(String? value) setSelectedFeedUrl;
  final String? selectedFeedUrl;
  final void Function(String text) onTapText;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: gridPadding,
      itemCount: searchResult.resultCount,
      gridDelegate: imageGridDelegate,
      itemBuilder: (context, index) {
        final podcastItem = searchResult.items.elementAt(index);

        final artworkUrl600 = podcastItem.artworkUrl600;
        final image = SafeNetworkImage(
          url: artworkUrl600,
          fit: BoxFit.cover,
          height: kSmallCardHeight,
          width: kSmallCardHeight,
        );

        return AudioCard(
          bottom: AudioCardBottom(text: podcastItem.collectionName),
          image: image,
          onPlay: () {
            if (podcastItem.feedUrl == null) return;
            findEpisodes(
              feedUrl: podcastItem.feedUrl!,
              itemImageUrl: artworkUrl600,
              genre: podcastItem.primaryGenreName,
            ).then((feed) {
              if (feed.isNotEmpty) {
                runOrConfirm(
                  context: context,
                  message: feed.length.toString(),
                  noConfirm: feed.length < kAudioQueueThreshHold,
                  run: () => startPlaylist(feed, podcastItem.feedUrl!),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.podcastFeedIsEmpty)),
                );
              }
            });
          },
          onTap: () async => await searchAndPushPodcastPage(
            context: context,
            podcastItem: podcastItem,
            podcastSubscribed: podcastSubscribed,
            onTapText: ({required AudioType audioType, required String text}) =>
                onTapText(text),
            removePodcast: removePodcast,
            addPodcast: addPodcast,
            setFeedUrl: setSelectedFeedUrl,
            oldFeedUrl: selectedFeedUrl,
            itemImageUrl: artworkUrl600,
            genre: podcastItem.primaryGenreName,
          ),
        );
      },
    );
  }
}

Future<void> searchAndPushPodcastPage({
  required BuildContext context,
  required Item podcastItem,
  required bool Function(String? feedUrl) podcastSubscribed,
  required void Function({
    required String text,
    required AudioType audioType,
  }) onTapText,
  required void Function(String feedUrl) removePodcast,
  required void Function(String feedUrl, Set<Audio> audios) addPodcast,
  required void Function(String? feedUrl) setFeedUrl,
  required String? oldFeedUrl,
  String? itemImageUrl,
  String? genre,
}) async {
  if (podcastItem.feedUrl == null) return;

  setFeedUrl(podcastItem.feedUrl);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 20),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(context.l10n.search),
          const Progress(),
        ],
      ),
    ),
  );

  await findEpisodes(
    feedUrl: podcastItem.feedUrl!,
    itemImageUrl: itemImageUrl,
    genre: genre,
  ).then((podcast) async {
    if (oldFeedUrl == podcastItem.feedUrl || podcast.isEmpty) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final subscribed = podcastSubscribed(podcastItem.feedUrl);
          final id = podcastItem.feedUrl;

          ScaffoldMessenger.of(context).clearSnackBars();

          return PodcastPage(
            subscribed: subscribed,
            imageUrl: podcastItem.artworkUrl600,
            addPodcast: addPodcast,
            removePodcast: removePodcast,
            onTextTap: onTapText,
            audios: podcast,
            pageId: id!,
            title: podcast.firstOrNull?.album ??
                podcast.firstOrNull?.title ??
                podcastItem.feedUrl!,
          );
        },
      ),
    ).then((_) => setFeedUrl(null));
  });
}
