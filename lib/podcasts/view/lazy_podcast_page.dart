import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/progress.dart';
import '../episodes_manager.dart';
import 'lazy_podcast_loading_page.dart';
import 'podcast_error_page.dart';
import 'podcast_page.dart';

class LazyPodcastPage extends StatelessWidget with WatchItMixin {
  const LazyPodcastPage({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) =>
      watchValue(
        (EpisodesManager m) => m.command.results,
        param1: feedUrl,
      ).toWidget(
        whileRunning: (lastResult, param) =>
            const LazyPodcastLoadingPage(child: Center(child: Progress())),
        onError: (error, lastResult, param) =>
            PodcastErrorPage(error: error, feedUrl: feedUrl),
        onData: (result, param) => PodcastPage(
          imageUrl:
              result?.firstOrNull?.albumArtUrl ?? result?.firstOrNull?.imageUrl,
          feedUrl: feedUrl,
        ),
      );
}
