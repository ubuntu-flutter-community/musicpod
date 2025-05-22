import 'package:flutter/material.dart';

import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/like_icon_button.dart';
import '../../common/view/stared_station_icon_button.dart';
import '../../extensions/build_context_x.dart';

class BottomPlayerLikeAndStarButton extends StatelessWidget {
  const BottomPlayerLikeAndStarButton({super.key, required this.audio});

  final Audio? audio;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return switch (audio?.audioType) {
      AudioType.local => LikeIconButton(
        audio: audio,
        color: theme.colorScheme.onSurface,
      ),
      AudioType.radio => StaredStationIconButton(audio: audio),
      _ => const SizedBox.shrink(),
    };
  }
}
