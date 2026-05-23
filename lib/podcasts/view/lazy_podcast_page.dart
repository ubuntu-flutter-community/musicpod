import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../data/podcast_update_capsule.dart';
import '../podcast_manager.dart';
import 'lazy_podcast_loading_page.dart';
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
      (context) => di<PodcastManager>().updatesCommand.run(
        PodcastUpdateCapsule(
          type: PodcastUpdateType.remove,
          feedUrls: [feedUrl],
        ),
      ),
    );

    final cooldown = watchValue((PodcastManager m) => m.cooldown);

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
      onError: (error, lastResult, param) =>
          _errorBody(feedUrl, context, cooldown),
      onData: (result, param) {
        final episodes = result;

        final newImageUrl =
            _imageUrl() ??
            episodes.firstOrNull?.albumArtUrl ??
            episodes.firstOrNull?.imageUrl;

        if (episodes.isEmpty) {
          return _errorBody(feedUrl, context, cooldown);
        }

        return PodcastPage(
          imageUrl: newImageUrl,
          episodes: episodes,
          feedUrl: feedUrl,
          title: _getTitle(feedUrl, context),
        );
      },
    );
  }

  LazyPodcastLoadingPage _errorBody(
    String feedUrl,
    BuildContext context,
    int cooldown,
  ) {
    return LazyPodcastLoadingPage(
      title: _getTitle(feedUrl, context),
      imageUrl: imageUrl,
      expandChild: true,
      child: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            spacing: kLargestSpace,
            children: [
              Text(
                context.l10n.findEpisodesTimeoutMessage(
                  _getTitle(feedUrl, context),
                ),
              ),
              FilledButton.icon(
                onPressed: () => di<PodcastManager>().maybeRunEpisodesCommand(
                  feedUrl: feedUrl,
                  podcastItem: podcastItem,
                  clearErrors: true,
                ),
                label: Text(context.l10n.retryngInSeconds(cooldown.toString())),
              ),
            ],
          ),
        ),
      ),
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
