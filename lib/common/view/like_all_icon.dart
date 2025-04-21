import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../library/library_model.dart';
import '../data/audio.dart';
import 'animated_like_icon.dart';

class LikeAllIcon extends StatelessWidget with WatchItMixin {
  const LikeAllIcon({super.key, required this.audios});

  final List<Audio> audios;

  @override
  Widget build(BuildContext context) {
    final likedAudios =
        watchPropertyValue((LibraryModel m) => m.favoriteAudios);
    final libraryModel = di<LibraryModel>();

    final liked = Set.from(likedAudios).containsAll(audios);
    return IconButton(
      onPressed: () => liked
          ? libraryModel.removeFavoriteAudios(audios)
          : libraryModel.addFavoriteAudios(audios),
      icon: AnimatedHeart(liked: liked),
    );
  }
}
