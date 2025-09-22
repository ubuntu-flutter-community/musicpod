import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../podcast_model.dart';

class PodcastRefreshButton extends StatelessWidget {
  const PodcastRefreshButton({super.key, required this.pageId});

  final String pageId;

  @override
  Widget build(BuildContext context) {
    final podcast = di<PodcastModel>().getPodcastEpisodesFromCache(pageId);

    return IconButton(
      tooltip: context.l10n.checkForUpdates,
      onPressed: podcast == null
          ? null
          : () => di<PodcastModel>().update(
              feedUrls: {pageId},
              updateMessage: context.l10n.newEpisodeAvailable,
            ),
      icon: Icon(Iconz.refresh),
    );
  }
}
