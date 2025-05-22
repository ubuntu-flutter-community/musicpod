import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../podcast_model.dart';

class PodcastRefreshButton extends StatelessWidget {
  const PodcastRefreshButton({super.key, required this.pageId});

  final String pageId;

  @override
  Widget build(BuildContext context) {
    final podcast = di<LibraryModel>().getPodcast(pageId);

    return IconButton(
      tooltip: context.l10n.checkForUpdates,
      onPressed: podcast == null
          ? null
          : () => di<PodcastModel>().update(
              oldPodcasts: {pageId: podcast},
              updateMessage: context.l10n.newEpisodeAvailable,
            ),
      icon: Icon(Iconz.refresh),
    );
  }
}
