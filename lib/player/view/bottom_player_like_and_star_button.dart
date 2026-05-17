import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/like_icon_button.dart';
import '../../extensions/build_context_x.dart';
import '../../radio/view/radio_page_star_button.dart';
import '../player_model.dart';

class BottomPlayerLikeAndStarButton extends StatelessWidget with WatchItMixin {
  const BottomPlayerLikeAndStarButton({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    return Builder(
      key: ObjectKey(audio),
      builder: (context) => switch (audio?.audioType) {
        AudioType.local => LikeIconButton(
          audio: audio,
          color: context.colorScheme.onSurface,
        ),
        AudioType.radio => RadioPageStarButton(station: audio!),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
