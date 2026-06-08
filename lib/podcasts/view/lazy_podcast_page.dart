import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/progress.dart';
import '../../extensions/command_x.dart';
import '../episodes_manager.dart';
import 'lazy_podcast_loading_page.dart';
import 'podcast_error_page.dart';
import 'podcast_page.dart';

class LazyPodcastPage extends StatelessWidget with WatchItMixin {
  const LazyPodcastPage({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final episodesManager = di<EpisodesManager>(param1: feedUrl, param2: null);
    callOnceAfterThisBuild((_) => episodesManager.command.runRestricted());

    final results = watch(episodesManager.command.results).value;
    final error = results.error;
    final isRunning = results.isRunning;

    if (isRunning) {
      return const LazyPodcastLoadingPage(child: Center(child: Progress()));
    }

    if (error != null) {
      return PodcastErrorPage(error: error, feedUrl: feedUrl);
    }

    final episodes = results.data;

    return PodcastPage(
      imageUrl:
          episodes?.firstOrNull?.albumArtUrl ?? episodes?.firstOrNull?.imageUrl,
      feedUrl: feedUrl,
    );
  }
}
