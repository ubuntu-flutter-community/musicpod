import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/view/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../podcast_model.dart';

class PodcastSubButton extends StatelessWidget with WatchItMixin {
  const PodcastSubButton({
    super.key,
    required this.pageId,
    required this.audios,
  });

  final String pageId;
  final List<Audio> audios;

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();

    final subscribed =
        watchPropertyValue((LibraryModel m) => m.isPodcastSubscribed(pageId));
    final checkingForUpdates =
        watchPropertyValue((PodcastModel m) => m.checkingForUpdates);

    final disabled = checkingForUpdates || pageId.isEmpty;
    return IconButton(
      isSelected: subscribed,
      tooltip: subscribed
          ? context.l10n.removeFromCollection
          : context.l10n.addToCollection,
      icon: checkingForUpdates
          ? const SideBarProgress()
          : Icon(
              subscribed ? Iconz.removeFromLibrary : Iconz.addToLibrary,
              color:
                  subscribed || disabled ? null : context.colorScheme.primary,
            ),
      onPressed: disabled
          ? null
          : () {
              if (subscribed) {
                libraryModel.removePodcast(pageId);
                di<RoutingManager>().pop();
              } else if (audios.isNotEmpty) {
                libraryModel.addPodcast(pageId, audios);
              }
            },
    );
  }
}
