import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/data/play_anywhere_param.dart';
import '../../app/play_anywhere_manager.dart';
import '../../app/routing_manager.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/icons.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../manager/podcast_short_info_manager.dart';

class PodcastCollectionCard extends StatelessWidget with WatchItMixin {
  const PodcastCollectionCard({
    super.key,
    required this.feedUrl,
    required this.hasUpdated,
  });

  final String feedUrl;
  final bool hasUpdated;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final shortInfo = watchValue(
      (PodcastShortInfoManager m) => m.command,
      param1: feedUrl,
    );
    return AudioCard(
      image: SafeNetworkImage(
        url: shortInfo?.imageUrl,
        fit: BoxFit.cover,
        height: audioCardDimension,
        width: audioCardDimension,
        fallbackWidget: const Center(),
        errorWidget: Center(
          child: Icon(Iconz.podcast, size: audioCardDimension * 0.7),
        ),
      ),
      bottom: AudioCardBottom(
        style: hasUpdated
            ? theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ) ??
                  TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  )
            : null,
        text: shortInfo?.name ?? context.l10n.podcast,
      ),
      onPlay: () => di<PlayAnywhereManager>().command.run(
        PlayAnywhereParam(
          pageId: feedUrl,
          audioPageType: AudioPageType.podcast,
        ),
      ),
      onTap: () => di<RoutingManager>().push(pageId: feedUrl),
    );
  }
}
