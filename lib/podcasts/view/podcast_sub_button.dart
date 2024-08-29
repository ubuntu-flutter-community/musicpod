import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
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

    return IconButton(
      isSelected: subscribed,
      tooltip: subscribed
          ? context.l10n.removeFromCollection
          : context.l10n.addToCollection,
      icon: checkingForUpdates
          ? const SideBarProgress()
          : Icon(
              subscribed ? Iconz().removeFromLibrary : Iconz().addToLibrary,
            ),
      onPressed: checkingForUpdates
          ? null
          : () {
              if (subscribed) {
                libraryModel.removePodcast(pageId);
              } else if (audios.isNotEmpty) {
                libraryModel.addPodcast(pageId, audios);
              }
            },
    );
  }
}
