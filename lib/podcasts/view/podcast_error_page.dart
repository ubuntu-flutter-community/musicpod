import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/command_x.dart';
import '../../extensions/object_x.dart';
import '../data/find_episodes_param.dart';
import '../episodes_manager.dart';
import 'lazy_podcast_loading_page.dart';

class PodcastErrorPage extends StatelessWidget with WatchItMixin {
  const PodcastErrorPage({
    super.key,
    required this.error,
    this.imageUrl,
    required this.feedUrl,
  });

  final Object error;
  final String? imageUrl;
  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final manager = di<EpisodesManager>(param1: feedUrl, param2: null);

    callAfterEveryBuild((_, _) {
      manager.command.runRestricted();
    });

    final cooldown = watch(manager.command.cooldown).value;
    return LazyPodcastLoadingPage(
      title: context.l10n.oopsSomethingWentWrong,
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
                onPressed: () => manager.command.runRestricted(
                  runWhen: RunWhen.hasNoValueAndNoErrors,
                  immediatelyClearErrors: true,
                  param: FindEpisodesParam(
                    feedUrl: feedUrl,
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
