import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/command_x.dart';
import '../data/find_episodes_param.dart';
import '../podcast_manager.dart';
import 'lazy_podcast_loading_page.dart';
import 'podcast_error_page.dart';
import 'podcast_page.dart';

class LazyPodcastPage extends StatelessWidget with WatchItMixin {
  const LazyPodcastPage({super.key, this.podcastItem, required this.feedUrl});

  final String feedUrl;
  final Item? podcastItem;

  @override
  Widget build(BuildContext context) {
    callOnceAfterThisBuild((_) {
      di<PodcastManager>()
          .getEpisodesCommand(feedUrl)
          .runRestricted(
            param: FindEpisodesParam(
              feedUrl: feedUrl,
              item: podcastItem,
              tryFromDbOnly: true,
            ),
          );
    });

    return watchValue(
      (PodcastManager m) => m.getEpisodesCommand(feedUrl).results,
    ).toWidget(
      whileRunning: (lastResult, param) => LazyPodcastLoadingPage(
        title: _getTitle(feedUrl, context),
        imageUrl: _itemImageUrl,
        child: const Center(child: Progress()),
      ),
      onError: (error, lastResult, param) => PodcastErrorPage(
        error: error,
        imageUrl: _itemImageUrl,
        title: _getTitle(feedUrl, context),
        feedUrl: feedUrl,
        podcastItem: podcastItem,
      ),
      onData: (episodes, param) => PodcastPage(
        imageUrl:
            _itemImageUrl ??
            episodes?.firstOrNull?.albumArtUrl ??
            episodes?.firstOrNull?.imageUrl,
        feedUrl: feedUrl,
        title: _getTitle(feedUrl, context),
      ),
    );
  }

  String? get _itemImageUrl =>
      podcastItem?.artworkUrl600 ?? podcastItem?.artworkUrl;

  String _getTitle(String feedUrl, BuildContext context) {
    return di<PodcastManager>().getSubscribedPodcastName(feedUrl) ??
        podcastItem?.collectionName ??
        podcastItem?.trackName ??
        context.l10n.podcast;
  }
}
