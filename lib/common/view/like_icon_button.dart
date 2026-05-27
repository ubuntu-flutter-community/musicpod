import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/page_ids.dart';
import '../../extensions/build_context_x.dart';
import '../../local_audio/local_audio_manager.dart';
import '../../playlists/view/add_to_playlist_snack_bar.dart';
import '../data/audio.dart';
import 'animated_like_icon.dart';

class LikeIconButton extends StatelessWidget with WatchItMixin {
  const LikeIconButton({super.key, required this.audio, this.color});

  final Audio? audio;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final localAudioManager = di<LocalAudioManager>();

    final liked = watchValue(
      (LocalAudioManager m) =>
          m.likedAudiosCommand.select((e) => e.contains(audio)),
    );

    final void Function()? onLike;
    if (audio == null) {
      onLike = null;
    } else {
      onLike = () {
        if (liked) {
          localAudioManager.removeLikedAudios([audio!]);
        } else {
          localAudioManager.addLikedAudios([audio!]);
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
