import '../../library/library_model.dart';
import '../data/audio.dart';
import 'icons.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class LikeAllIcon extends StatelessWidget with WatchItMixin {
  const LikeAllIcon({super.key, required this.audios});

  final Set<Audio> audios;

  @override
  Widget build(BuildContext context) {
    final likedAudios = watchPropertyValue((LibraryModel m) => m.likedAudios);
    final libraryModel = di<LibraryModel>();

    final liked = likedAudios.containsAll(audios);
    return IconButton(
      onPressed: () => liked
          ? libraryModel.removeLikedAudios(audios)
          : libraryModel.addLikedAudios(audios),
      icon: Iconz().getAnimatedHeartIcon(liked: liked),
    );
  }
}
