import 'dart:async';

import 'package:flutter/material.dart';

import '../common/view/snackbars.dart';
import '../library/library_model.dart';
import '../player/player_model.dart';
import 'podcast_model.dart';
import 'view/podcast_page.dart';
import 'view/podcast_snackbar_contents.dart';

Future<void> searchAndPushPodcastPage({
  required BuildContext context,
  required PodcastModel podcastModel,
  required PlayerModel playerModel,
  required LibraryModel libraryModel,
  required String? feedUrl,
  String? itemImageUrl,
  String? genre,
  required bool startPlaylist,
}) async {
  if (feedUrl == null) {
    showSnackBar(
      context: context,
      content: const PodcastSearchEmptyFeedSnackBarContent(),
    );
    return;
  }

  if (libraryModel.isPageInLibrary(feedUrl)) {
    return libraryModel.pushNamed(pageId: feedUrl);
  }

  showSnackBar(
    context: context,
    duration: const Duration(seconds: 1000),
    content: const PodcastSearchLoadingSnackBarContent(),
  );

  podcastModel.setLoadingFeed(true);
  return podcastModel
      .findEpisodes(
    feedUrl: feedUrl,
    itemImageUrl: itemImageUrl,
    genre: genre,
  )
      .then(
    (podcast) async {
      if (podcast.isEmpty) {
        if (context.mounted) {
          showSnackBar(
            context: context,
            content: const PodcastSearchEmptyFeedSnackBarContent(),
          );
        }
        return;
      }

      if (startPlaylist) {
        playerModel.startPlaylist(listName: feedUrl, audios: podcast);
      } else {
        libraryModel.push(
          builder: (_) => PodcastPage(
            imageUrl: itemImageUrl ?? podcast.firstOrNull?.imageUrl,
            preFetchedEpisodes: podcast,
            feedUrl: feedUrl,
            title: podcast.firstOrNull?.album ??
                podcast.firstOrNull?.title ??
                feedUrl,
          ),
          pageId: feedUrl,
        );
      }
    },
  ).whenComplete(
    () {
      podcastModel.setLoadingFeed(false);
      if (context.mounted) ScaffoldMessenger.of(context).clearSnackBars();
    },
  ).timeout(
    const Duration(seconds: 15),
    onTimeout: () {
      if (context.mounted) {
        showSnackBar(
          context: context,
          content: const PodcastSearchTimeoutSnackBarContent(),
        );
      }
    },
  );
}
