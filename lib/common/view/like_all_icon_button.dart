import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../local_audio/manager/liked_audio_paths_manager.dart';
import '../data/audio.dart';
import 'animated_like_icon.dart';

class LikeAllIconButton extends StatelessWidget with WatchItMixin {
  const LikeAllIconButton({super.key, required this.audios});

  final List<Audio> audios;

  @override
  Widget build(BuildContext context) {
    final audioPaths = audios.map((a) => a.path).whereType<String>().toSet();
    final liked = watchValue(
      (LikedAudioPathsManager m) => m.command.select(
        (paths) => audioPaths.isNotEmpty && paths.containsAll(audioPaths),
      ),
    );

    final likedAudioPathsManager = di<LikedAudioPathsManager>();
    return IconButton(
      onPressed: () => liked
          ? likedAudioPathsManager.removeLikedAudios(audios)
          : likedAudioPathsManager.addLikedAudios(audios),
      icon: AnimatedHeart(liked: liked),
    );
  }
}
