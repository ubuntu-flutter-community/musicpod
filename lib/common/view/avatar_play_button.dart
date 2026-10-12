import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data/play_anywhere_param.dart';
import '../../app/play_anywhere_manager.dart';
import '../../extensions/build_context_x.dart';
import '../../player/manager/play_pause_manager.dart';
import '../../player/manager/queue_manager.dart';
import 'audio_page_type.dart';
import 'icons.dart';
import 'ui_constants.dart';

class AvatarPlayButton extends ConsumerWidget {
  const AvatarPlayButton({
    super.key,
    required this.pageId,
    required this.audioPageType,
    this.onPressed,
  });

  final String pageId;
  final AudioPageType audioPageType;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final isPlayerPlaying = ref.watch(playPauseManagerProvider);
    final pageIsQueue = ref.watch(
      queueManagerProvider.select((q) => q.name == pageId),
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
        onPressed:
            onPressed ??
            () => ref
                .read(playAnywhereManagerProvider.notifier)
                .play(
                  PlayAnywhereParam(
                    audioPageType: audioPageType,
                    pageId: pageId,
                  ),
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

