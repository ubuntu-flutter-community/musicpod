import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../podcast_model.dart';
import 'lazy_podcast_loading_page.dart';
import 'podcast_page.dart';

class LazyPodcastPage extends StatefulWidget with WatchItStatefulWidgetMixin {
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
  State<LazyPodcastPage> createState() => _LazyPodcastPageState();
}

class _LazyPodcastPageState extends State<LazyPodcastPage> {
  late Future<List<Audio>?> _episodes;
  String? url;

  @override
  void initState() {
    super.initState();
    url = widget.feedUrl ?? widget.podcastItem?.feedUrl;
    _episodes = di<PodcastModel>().findEpisodes(
      item: widget.podcastItem,
      feedUrl: url,
      addUpdates: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _episodes,
      builder: (context, snapshot) {
        final feedUrl = widget.feedUrl ?? widget.podcastItem?.feedUrl;
        final title =
            (feedUrl == null
                ? null
                : di<LibraryModel>().getSubscribedPodcastName(feedUrl)) ??
            widget.podcastItem?.collectionName ??
            widget.podcastItem?.trackName ??
            context.l10n.podcast;
        final imageUrl =
            widget.imageUrl ??
            widget.podcastItem?.artworkUrl600 ??
            widget.podcastItem?.artworkUrl ??
            snapshot.data?.first.albumArtUrl ??
            snapshot.data?.first.imageUrl;

        if (!snapshot.hasData) {
          return LazyPodcastLoadingPage(
            title: title,
            imageUrl: imageUrl,
            child: const Center(child: Progress()),
          );
        }

        if (snapshot.hasError) {
          return LazyPodcastLoadingPage(
            title: title,
            imageUrl: imageUrl,
            child: NoSearchResultPage(message: Text(snapshot.error.toString())),
          );
        }

        final episodes = snapshot.data!;

        if (feedUrl == null || episodes.isEmpty) {
          return LazyPodcastLoadingPage(
            title: title,
            imageUrl: imageUrl,
            child: NoSearchResultPage(
              message: Text(context.l10n.podcastFeedIsEmpty),
            ),
          );
        }

        return PodcastPage(
          imageUrl: imageUrl,
          episodes: episodes,
          feedUrl: feedUrl,
          title: title,
        );
      },
    );
  }
}
