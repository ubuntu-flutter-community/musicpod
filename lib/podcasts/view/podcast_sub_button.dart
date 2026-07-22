import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../data/podcast_toggle_capsule.dart';
import '../manager/subscribed_podcasts_manager.dart';

class PodcastSubButton extends StatelessWidget with WatchItMixin {
  const PodcastSubButton({
    super.key,
    required this.pageId,
    this.imageUrl,
    required this.name,
    required this.artist,
  });

  final String pageId;
  final String? imageUrl;
  final String name;
  final String artist;

  @override
  Widget build(BuildContext context) {
    final subscribed = watchValue(
      (SubscribedPodcastsManager m) => m.command,
    ).contains(pageId);

    final disabled = pageId.isEmpty;
    return IconButton(
      isSelected: subscribed,
      tooltip: subscribed
          ? context.l10n.removeFromCollection
          : context.l10n.addToCollection,
      icon: Icon(
        subscribed ? Iconz.removeFromLibrary : Iconz.addToLibrary,
        color: subscribed || disabled ? null : context.colorScheme.primary,
      ),
      onPressed: disabled
          ? null
          : () => di<SubscribedPodcastsManager>().command.run(
              PodcastToggleCapsule(
                feedUrl: pageId,
                imageUrl: imageUrl,
                name: name,
                artist: artist,
              ),
            ),
    );
  }
}
