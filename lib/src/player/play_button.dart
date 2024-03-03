import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../build_context_x.dart';
import '../../l10n.dart';
import '../common/icons.dart';
import 'player_model.dart';

class PlayButton extends ConsumerWidget {
  const PlayButton({
    super.key,
    required this.active,
    this.iconColor,
  });

  final bool active;
  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerModel = ref.read(playerModelProvider);
    final pause = playerModel.pause;
    final playOrPause = playerModel.playOrPause;
    final isPlaying = ref.watch(playerModelProvider.select((m) => m.isPlaying));
    return IconButton(
      tooltip: isPlaying ? context.l10n.pause : context.l10n.play,
      color: iconColor ?? context.t.colorScheme.onSurface,
      onPressed: !active
          ? null
          : () {
              if (isPlaying) {
                pause();
              } else {
                playOrPause();
              }
            },
      icon: isPlaying
          ? Icon(Iconz().pause)
          : Icon(
              Iconz().playFilled,
            ),
    );
  }
}
