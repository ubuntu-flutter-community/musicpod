import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/data/play_anywhere_param.dart';
import '../../app/play_anywhere_manager.dart';
import '../../extensions/build_context_x.dart';
import '../../player/manager/player_manager.dart';
import 'audio_page_type.dart';
import 'icons.dart';
import 'ui_constants.dart';

class AvatarPlayButton extends StatelessWidget with WatchItMixin {
  const AvatarPlayButton({
    super.key,
    required this.pageId,
    required this.audioPageType,
  });

  final String pageId;
  final AudioPageType audioPageType;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isPlayerPlaying = watchPropertyValue(
      (PlayerManager m) => m.isPlaying,
    );
    final pageIsQueue = watchPropertyValue(
      (PlayerManager m) => m.queue.name == pageId,
    );
    final iconData = isPlayerPlaying && pageIsQueue
        ? Iconz.pause
        : Iconz.playFilled;

    final label = context.l10n.playAll;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSmallestSpace),
      child: IconButton(
        style: IconButton.styleFrom(
          shape: const CircleBorder(),
          minimumSize: Size(
            context.buttonHeight * 1.4,
            context.buttonHeight * 1.4,
          ),
          maximumSize: Size(
            context.buttonHeight * 1.4,
            context.buttonHeight * 1.4,
          ),
          backgroundColor: theme.colorScheme.inverseSurface,
          foregroundColor: theme.colorScheme.onInverseSurface,
          hoverColor: theme.colorScheme.primary.withValues(alpha: 0.5),
          focusColor: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
        tooltip: label,
        onPressed: () => di<PlayAnywhereManager>().command.run(
          PlayAnywhereParam(audioPageType: audioPageType, pageId: pageId),
        ),
        icon: Icon(
          iconData,
          color: theme.colorScheme.onInverseSurface,
          semanticLabel: label,
        ),
      ),
    );
  }
}
