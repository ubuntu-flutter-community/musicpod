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
    final liked =
        watchPropertyValue((LibraryModel m) => m.isLikedAudios(audios));
    final libraryModel = di<LibraryModel>();
    return IconButton(
      onPressed: () => liked
          ? libraryModel.removeLikedAudios(audios)
          : libraryModel.addLikedAudios(audios),
      icon: AnimatedHeart(liked: liked),
    );
  }
}
