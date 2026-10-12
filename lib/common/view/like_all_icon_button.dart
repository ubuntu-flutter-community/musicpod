import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../local_audio/manager/liked_audio_paths_manager.dart';
import '../data/audio.dart';
import 'animated_like_icon.dart';

class LikeAllIconButton extends ConsumerWidget {
  const LikeAllIconButton({super.key, required this.audios});

  final List<Audio> audios;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPaths = audios.map((a) => a.path).whereType<String>().toSet();
    final liked = ref.watch(
      likedAudioPathsManagerProvider.select(
        (paths) =>
            audioPaths.isNotEmpty &&
            (paths.value?.containsAll(audioPaths) ?? false),
      ),
    );

    return IconButton(
      onPressed: () => liked
          ? ref
                .read(likedAudioPathsManagerProvider.notifier)
                .removeLikedAudios(audios)
          : ref
                .read(likedAudioPathsManagerProvider.notifier)
                .addLikedAudios(audios),
      icon: AnimatedHeart(liked: liked),
    );
  }
}
