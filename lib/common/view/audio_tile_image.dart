import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../local_audio/view/local_cover.dart';
import '../data/audio.dart';
import 'icons.dart';
import 'safe_network_image.dart';

class AudioTileImage extends StatelessWidget {
  const AudioTileImage({
    super.key,
    this.audio,
    required this.size,
  });
  final Audio? audio;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (audio?.audioType == AudioType.local) {
      image = LocalCover(
        albumId: audio!.albumId,
        path: audio!.path,
        fit: BoxFit.cover,
        dimension: size,
        fallback: Icon(
          switch (audio?.audioType) {
            AudioType.radio => Iconz().radio,
            AudioType.podcast => Iconz().podcast,
            _ => Iconz().musicNote,
          },
          size: size / (1.65),
        ),
      );
    } else {
      image = SafeNetworkImage(
        url: audio?.imageUrl ?? audio?.albumArtUrl,
        height: size,
        fit: BoxFit.cover,
      );
    }

    return SizedBox.square(
      dimension: kAudioTrackWidth,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: image,
      ),
    );
  }
}
