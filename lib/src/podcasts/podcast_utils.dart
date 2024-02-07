import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../globals.dart';
import '../../l10n.dart';
import '../../player.dart';
import '../../podcasts.dart';

Future<void> searchAndPushPodcastPage({
  required BuildContext context,
  required WidgetRef ref,
  required String? feedUrl,
  required String? itemImageUrl,
  required String? genre,
  required bool play,
}) async {
  ScaffoldMessenger.of(context).clearSnackBars();

  if (feedUrl == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.podcastFeedIsEmpty),
      ),
    );
    return;
  }
  final model = ref.read(podcastModelProvider);
  final startPlaylist = ref.read(playerModelProvider).startPlaylist;
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

  await findEpisodes(
    feedUrl: feedUrl,
    itemImageUrl: itemImageUrl,
    genre: genre,
  ).then((podcast) async {
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
      await navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) {
            final id = feedUrl;

            ScaffoldMessenger.of(context).clearSnackBars();

            return PodcastPage(
              imageUrl: itemImageUrl,
              audios: podcast,
              pageId: id,
              title: podcast.firstOrNull?.album ??
                  podcast.firstOrNull?.title ??
                  feedUrl,
            );
          },
        ),
      ).then((_) => setSelectedFeedUrl(null));
    }
  });
}
