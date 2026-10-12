import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../manager/play_pause_manager.dart';

class PlayButton extends ConsumerWidget {
  const PlayButton({
    super.key,
    required this.active,
    this.iconColor,
    this.buttonStyle,
  });

  final bool active;
  final Color? iconColor;
  final ButtonStyle? buttonStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(playPauseManagerProvider);
    final tooltip = isPlaying ? context.l10n.pause : context.l10n.play;
    return IconButton(
      style: buttonStyle,
      tooltip: tooltip,
      onPressed: !active
          ? null
          : () {
              final notifier = ref.read(playPauseManagerProvider.notifier);
              if (isPlaying) {
                notifier.pause();
              } else {
                notifier.playOrPause();
              }
            },
      icon: Icon(
        isPlaying ? Iconz.pause : Iconz.playFilled,
        color: iconColor ?? context.theme.colorScheme.onSurface,
        semanticLabel: tooltip,
      ),
    );
  }
}
