import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../globals.dart';
import '../../l10n.dart';
import '../../player.dart';
import '../../podcasts.dart';

void searchAndPushPodcastPage({
  required BuildContext context,
  required String? feedUrl,
  required String? itemImageUrl,
  required String? genre,
  required bool play,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();

  if (feedUrl == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.podcastFeedIsEmpty),
      ),
    );
    return;
  }
  final model = context.read<PodcastModel>();
  final startPlaylist = context.read<PlayerModel>().startPlaylist;
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

  findEpisodes(
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
      runOrConfirm(
        context: context,
        noConfirm: podcast.length < kAudioQueueThreshHold,
        message: context.l10n.queueConfirmMessage(podcast.length.toString()),
        run: () {
          startPlaylist.call(listName: feedUrl, audios: podcast).then(
                (_) => setSelectedFeedUrl(null),
              );
        },
        onCancel: () {
          model.setSelectedFeedUrl(null);
          ScaffoldMessenger.of(context).clearSnackBars();
        },
      );
    } else {
      navigatorKey.currentState
          ?.push(
            MaterialPageRoute(
              builder: (context) {
                return PodcastPage(
                  imageUrl: itemImageUrl,
                  audios: podcast,
                  pageId: feedUrl,
                  title: podcast.firstOrNull?.album ??
                      podcast.firstOrNull?.title ??
                      feedUrl,
                );
              },
            ),
          )
          .then((_) => setSelectedFeedUrl(null))
          .then((_) => ScaffoldMessenger.of(context).clearSnackBars());
    }
  });
}
