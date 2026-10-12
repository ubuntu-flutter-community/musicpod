import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/page_ids.dart';
import '../../extensions/build_context_x.dart';
import '../../local_audio/manager/liked_audio_paths_manager.dart';
import '../../local_audio/view/add_to_playlist_snack_bar.dart';
import '../data/audio.dart';
import 'animated_like_icon.dart';

class LikeIconButton extends ConsumerWidget {
  const LikeIconButton({super.key, required this.audio, this.color});

  final Audio? audio;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liked = ref.watch(
      likedAudioPathsManagerProvider.select(
        (asyncPaths) =>
            audio?.path != null &&
            (asyncPaths.value?.contains(audio!.path) ?? false),
      ),
    );

    final void Function()? onLike;
    if (audio == null) {
      onLike = null;
    } else {
      onLike = () {
        if (liked) {
          ref.read(likedAudioPathsManagerProvider.notifier).removeLikedAudios([
            audio!,
          ]);
        } else {
          ref.read(likedAudioPathsManagerProvider.notifier).addLikedAudios([
            audio!,
          ]);
          showAddedToPlaylistSnackBar(
            context: context,
            id: PageIDs.likedAudios,
          );
        }
      };
    }

    return IconButton(
      tooltip: liked
          ? context.l10n.removeFromFavorites
          : context.l10n.addToFavorites,
      icon: AnimatedHeart(liked: liked, color: color),
      onPressed: onLike,
      color: color,
    );
  }
}
