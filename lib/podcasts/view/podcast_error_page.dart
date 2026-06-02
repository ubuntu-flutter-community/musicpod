import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/command_x.dart';
import '../../extensions/object_x.dart';
import '../data/find_episodes_param.dart';
import '../podcast_manager.dart';
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
    callAfterEveryBuild((_, _) {
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

    final command = di<PodcastManager>().getEpisodesCommand(feedUrl);
    final cooldown = watch(command.cooldown).value;
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
              Text(error.localizedErrorMessage(context.l10n)),
              FilledButton.icon(
                onPressed: () => command.runRestricted(
                  runWhen: RunWhen.hasNoValueAndNoErrors,
                  immediatelyClearErrors: true,
                  param: FindEpisodesParam(
                    feedUrl: feedUrl,
                    item: podcastItem,
                    tryFromDbOnly: false,
                  ),
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
