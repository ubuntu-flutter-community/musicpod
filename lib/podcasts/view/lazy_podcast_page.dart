import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/connectivity_model.dart';
import '../../common/data/audio.dart';
import '../../common/logging.dart';
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
    required this.updateMessage,
    required this.multiUpdateMessage,
  });

  final Item? podcastItem;
  final String? feedUrl;
  final String? imageUrl;
  final String updateMessage;
  final String Function(int length) multiUpdateMessage;

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
    if (url == null) {
      printMessageInDebugMode('checkupdates called without feedUrl or item!');
      _episodes = Future.value(<Audio>[]);
    } else {
      _episodes = _findEpisodes(url!);
    }
  }

  Future<List<Audio>?> _findEpisodes(String url) async {
    final podcastModel = di<PodcastModel>();
    final libraryModel = di<LibraryModel>();
    if (libraryModel.isPodcastSubscribed(url) &&
        podcastModel.getPodcastEpisodesFromCache(url) == null) {
      await podcastModel.checkForUpdates(
        feedUrls: {url},
        updateMessage: widget.updateMessage,
        multiUpdateMessage: widget.multiUpdateMessage,
      );
    }

    final episodes = await podcastModel.findEpisodes(feedUrl: url);
    await libraryModel.removePodcastUpdate(url);

    return episodes;
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);

    return FutureBuilder(
      key: ValueKey(isOnline),
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
          isOnline: isOnline,
        );
      },
    );
  }
}
