import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../local_audio/local_audio_manager.dart';
import '../data/audio.dart';
import 'animated_like_icon.dart';

class LikeAllIconButton extends StatelessWidget with WatchItMixin {
  const LikeAllIconButton({super.key, required this.audios});

  final List<Audio> audios;

  @override
  Widget build(BuildContext context) {
    final liked = watchPropertyValue(
      (LocalAudioManager m) => m.isLikedAudios(audios),
    );
    final localAudioManager = di<LocalAudioManager>();
    return IconButton(
      onPressed: () => liked
          ? localAudioManager.removeLikedAudios(audios)
          : localAudioManager.addLikedAudios(audios),
      icon: AnimatedHeart(liked: liked),
    );
  }
}
