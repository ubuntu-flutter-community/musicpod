import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../common/view/icons.dart';
import '../player_model.dart';

class PlayButton extends StatelessWidget with WatchItMixin {
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
  Widget build(BuildContext context) {
    final playerModel = di<PlayerModel>();
    final pause = playerModel.pause;
    final playOrPause = playerModel.playOrPause;
    final isPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);
    final tooltip = isPlaying ? context.l10n.pause : context.l10n.play;
    return IconButton(
      style: buttonStyle,
      tooltip: tooltip,
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
        isPlaying ? Iconz.pause : Iconz.playFilled,
        color: iconColor ?? context.theme.colorScheme.onSurface,
        semanticLabel: tooltip,
      ),
    );
  }
}
