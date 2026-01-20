import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../playlists/view/add_to_playlist_snack_bar.dart';
import '../data/audio.dart';
import '../page_ids.dart';
import 'animated_like_icon.dart';

class LikeIconButton extends StatelessWidget with WatchItMixin {
  const LikeIconButton({super.key, required this.audio, this.color});

  final Audio? audio;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();

    watchPropertyValue((LibraryModel m) => m.likedAudiosLength);

    final liked = libraryModel.isLikedAudio(audio);

    final void Function()? onLike;
    if (audio == null) {
      onLike = null;
    } else {
      onLike = () {
        if (liked) {
          libraryModel.removeLikedAudio(audio!);
        } else {
          libraryModel.addLikedAudio(audio!);
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
