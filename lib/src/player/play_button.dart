import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../common/icons.dart';
import 'player_model.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.active,
    this.iconColor,
  });

  final bool active;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final playerModel = context.read<PlayerModel>();
    final pause = playerModel.pause;
    final playOrPause = playerModel.playOrPause;
    final isPlaying = context.select((PlayerModel m) => m.isPlaying);
    return IconButton(
      color: iconColor,
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
          : Padding(
              padding: EdgeInsets.only(left: appleStyled ? 3 : 0),
              child: Icon(
                Iconz().play,
              ),
            ),
    );
  }
}
