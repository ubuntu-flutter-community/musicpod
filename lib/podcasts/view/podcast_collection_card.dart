import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/routing_manager.dart';
import '../../app/sidebar_audios_manager.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
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
        fallbackWidget: Icon(Iconz.podcast, size: 70),
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
      onPlay: () => di<SidebarAudiosManager>().playAudiosByIdCommand.run((
        pageId: feedUrl,
      )),
      onTap: () => di<RoutingManager>().push(pageId: feedUrl),
    );
  }
}
