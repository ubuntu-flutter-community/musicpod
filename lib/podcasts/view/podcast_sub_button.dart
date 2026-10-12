import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../manager/subscribed_podcasts_manager.dart';

class PodcastSubButton extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final subscribed =
        ref.watch(subscribedPodcastsManagerProvider).value?.contains(pageId) ??
        false;

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
          : () => ref
                .read(subscribedPodcastsManagerProvider.notifier)
                .togglePodcastSubscription(
                  feedUrl: pageId,
                  imageUrl: imageUrl,
                  name: name,
                  artist: artist,
                ),
    );
  }
}
