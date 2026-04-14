import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/routing_manager.dart';
import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../podcast_manager.dart';

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
    final podcastManager = di<PodcastManager>();

    final subscribed = watchPropertyValue(
      (PodcastManager m) => m.isPodcastSubscribed(pageId),
    );

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
          : () async {
              if (subscribed) {
                podcastManager.removePodcast(pageId);
                di<RoutingManager>().pop();
              } else {
                podcastManager.addPodcast(
                  feedUrl: pageId,
                  imageUrl: imageUrl,
                  name: name,
                  artist: artist,
                );
              }
            },
    );
  }
}
