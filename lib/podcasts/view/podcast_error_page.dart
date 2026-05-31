import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../podcast_manager.dart';
import '../podcast_service.dart';
import 'lazy_podcast_loading_page.dart';

class PodcastErrorPage extends StatelessWidget with WatchItMixin {
  const PodcastErrorPage({
    super.key,
    required this.error,
    this.imageUrl,
    required this.title,
    required this.feedUrl,
    this.podcastItem,
  });

  final Object error;
  final String? imageUrl;
  final String title;
  final String feedUrl;
  final Item? podcastItem;

  @override
  Widget build(BuildContext context) {
    final cooldown = watchValue((PodcastManager m) => m.cooldown);
    return LazyPodcastLoadingPage(
      title: title,
      imageUrl: imageUrl,
      expandChild: true,
      child: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            spacing: kLargestSpace,
            children: [
              Text(switch (error) {
                FindEpisodesTimeoutException() =>
                  context.l10n.findEpisodesTimeoutMessage(title),
                PodcastFailedException() =>
                  (error as PodcastFailedException).message,
                _ => error.toString(),
              }),
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
}
