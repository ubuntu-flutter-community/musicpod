import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
