import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../local_audio/manager/liked_audios_manager.dart';
import '../data/audio.dart';
import 'animated_like_icon.dart';

class LikeAllIconButton extends StatelessWidget with WatchItMixin {
  const LikeAllIconButton({super.key, required this.audios});

  final List<Audio> audios;

  @override
  Widget build(BuildContext context) {
    final liked = watchValue(
      (LikedAudiosManager m) =>
          m.command.select((e) => e?.contains(audios) ?? false),
    );
    final likedAudiosManager = di<LikedAudiosManager>();
    return IconButton(
      onPressed: () => liked
          ? likedAudiosManager.removeLikedAudios(audios)
          : likedAudiosManager.addLikedAudios(audios),
      icon: AnimatedHeart(liked: liked),
    );
  }
}
