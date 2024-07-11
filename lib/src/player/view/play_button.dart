import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../build_context_x.dart';
import '../../../l10n.dart';
import '../../common/icons.dart';
import '../player_model.dart';

class PlayButton extends StatelessWidget with WatchItMixin {
  const PlayButton({
    super.key,
    required this.active,
    this.iconColor,
  });

  final bool active;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final playerModel = di<PlayerModel>();
    final pause = playerModel.pause;
    final playOrPause = playerModel.playOrPause;
    final isPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);
    return IconButton(
      tooltip: isPlaying ? context.l10n.pause : context.l10n.play,
      onPressed: !active
          ? null
          : () {
              if (isPlaying) {
                pause();
              } else {
                playOrPause();
              }
            },
      icon: Icon(
        isPlaying ? Iconz().pause : Iconz().playFilled,
        color: iconColor ?? context.t.colorScheme.onSurface,
      ),
    );
  }
}
