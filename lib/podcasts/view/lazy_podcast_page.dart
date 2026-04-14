import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../app/connectivity_manager.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../l10n/l10n.dart';
import '../podcast_manager.dart';
import 'lazy_podcast_loading_page.dart';
import 'podcast_page.dart';

class LazyPodcastPage extends StatelessWidget with WatchItMixin {
  const LazyPodcastPage({
    super.key,
    this.podcastItem,
    this.feedUrl,
    this.imageUrl,
    required this.updateMessage,
    required this.multiUpdateMessage,
  });

  final Item? podcastItem;
  final String? feedUrl;
  final String? imageUrl;
  final String updateMessage;
  final String Function(int length) multiUpdateMessage;

  @override
  Widget build(BuildContext context) {
    final connectivityCommand = watchValue(
      (ConnectivityManager m) => m.connectivityCommand,
    );

    final showDownloadsOnly = watchValue((PodcastManager m) => m.downloadsOnly);

    final feedUrl = this.feedUrl ?? podcastItem?.feedUrl;

    if (feedUrl == null) {
      return LazyPodcastLoadingPage(
        title: context.l10n.podcast,
        imageUrl: this.imageUrl,
        child: NoSearchResultPage(
          message: Text(context.l10n.podcastFeedIsEmpty),
        ),
      );
    }

    callOnceAfterThisBuild(
      (context) => di<PodcastManager>().removePodcastUpdate(feedUrl),
    );

    if (di<PodcastManager>().shouldRunCommand(feedUrl) &&
            connectivityCommand.isOnline ||
        !connectivityCommand.wasOnline && connectivityCommand.isOnline) {
      di<PodcastManager>().getEpisodesCommand(feedUrl).run((
        feedUrl: feedUrl,
        item: podcastItem,
      ));
    }

    final title =
        di<PodcastManager>().getSubscribedPodcastName(feedUrl) ??
        podcastItem?.collectionName ??
        podcastItem?.trackName ??
        context.l10n.podcast;

    final imageUrl =
        this.imageUrl ?? podcastItem?.artworkUrl600 ?? podcastItem?.artworkUrl;

    return watchValue(
      (PodcastManager m) => m.getEpisodesCommand(feedUrl).results,
    ).toWidget(
      whileRunning: (lastResult, param) => LazyPodcastLoadingPage(
        title: title,
        imageUrl: imageUrl,
        child: const Center(child: Progress()),
      ),
      onError: (error, lastResult, param) => LazyPodcastLoadingPage(
        title: title,
        imageUrl: imageUrl,
        child: NoSearchResultPage(message: Text(error.toString())),
      ),
      onData: (result, param) {
        final episodes = result;

        final newImageUrl =
            imageUrl ??
            episodes.firstOrNull?.albumArtUrl ??
            episodes.firstOrNull?.imageUrl;

        return PodcastPage(
          imageUrl: newImageUrl,
          episodes: episodes,
          feedUrl: feedUrl,
          title: title,
          showDownloadsOnly: showDownloadsOnly,
        );
      },
    );
  }
}
