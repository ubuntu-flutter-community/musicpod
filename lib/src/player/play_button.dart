import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '../common/icons.dart';
import 'player_service.dart';

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
    final service = getService<PlayerService>();
    final pause = service.pause;
    final playOrPause = service.playOrPause;
    final isPlaying = service.isPlaying.watch(context);
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
          : Icon(
              Iconz().playFilled,
            ),
    );
  }
}
