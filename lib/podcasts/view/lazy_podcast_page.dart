import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../podcast_manager.dart';
import 'lazy_podcast_loading_page.dart';
import 'podcast_error_page.dart';
import 'podcast_page.dart';

class LazyPodcastPage extends StatelessWidget with WatchItMixin {
  const LazyPodcastPage({
    super.key,
    this.podcastItem,
    this.feedUrl,
    this.imageUrl,
  });

  final Item? podcastItem;
  final String? feedUrl;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final feedUrl = this.feedUrl ?? podcastItem?.feedUrl;

    if (feedUrl == null || feedUrl.isEmpty) {
      return LazyPodcastLoadingPage(
        title: context.l10n.podcast,
        imageUrl: this.imageUrl,
        child: NoSearchResultPage(
          message: Text(context.l10n.podcastFeedIsEmpty),
        ),
      );
    }

    di<PodcastManager>().maybeRunEpisodesCommand(
      feedUrl: feedUrl,
      podcastItem: podcastItem,
      clearErrors: false,
    );

    return watchValue(
      (PodcastManager m) => m.getEpisodesCommand(feedUrl).results,
    ).toWidget(
      whileRunning: (lastResult, param) => LazyPodcastLoadingPage(
        title: _getTitle(feedUrl, context),
        imageUrl: _imageUrl(),
        child: const Center(child: Progress()),
      ),
      onError: (error, lastResult, param) => PodcastErrorPage(
        error: error,
        imageUrl: _imageUrl(),
        title: _getTitle(feedUrl, context),
        feedUrl: feedUrl,
        podcastItem: podcastItem,
      ),
      onData: (result, param) {
        final episodes = result;

        final newImageUrl =
            _imageUrl() ??
            episodes.firstOrNull?.albumArtUrl ??
            episodes.firstOrNull?.imageUrl;

        if (episodes.isEmpty) {
          return LazyPodcastLoadingPage(
            title: _getTitle(feedUrl, context),
            imageUrl: newImageUrl,
            child: NoSearchResultPage(
              message: Text(context.l10n.podcastFeedIsEmpty),
            ),
          );
        }

        return PodcastPage(
          imageUrl: newImageUrl,
          feedUrl: feedUrl,
          title: _getTitle(feedUrl, context),
        );
      },
    );
  }

  String? _imageUrl() =>
      this.imageUrl ?? podcastItem?.artworkUrl600 ?? podcastItem?.artworkUrl;

  String _getTitle(String feedUrl, BuildContext context) {
    return di<PodcastManager>().getSubscribedPodcastName(feedUrl) ??
        podcastItem?.collectionName ??
        podcastItem?.trackName ??
        context.l10n.podcast;
  }
}
