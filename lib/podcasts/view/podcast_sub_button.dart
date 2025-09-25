import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/view/routing_manager.dart';
import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';

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
    final libraryModel = di<LibraryModel>();

    final subscribed = watchPropertyValue(
      (LibraryModel m) => m.isPodcastSubscribed(pageId),
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
                libraryModel.removePodcast(pageId);
                di<RoutingManager>().pop();
              } else {
                libraryModel.addPodcast(
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
