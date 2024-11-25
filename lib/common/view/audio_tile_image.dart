import 'package:flutter/material.dart';

import 'ui_constants.dart';
import '../../local_audio/view/local_cover.dart';
import '../data/audio.dart';
import '../data/audio_type.dart';
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
    final icon = Icon(
      switch (audio?.audioType) {
        AudioType.radio => Iconz.radio,
        AudioType.podcast => Iconz.podcast,
        _ => Iconz.musicNote,
      },
      size: size / (1.65),
    );
    Widget image;
    if (audio?.hasPathAndId == true) {
      image = LocalCover(
        albumId: audio!.albumId!,
        path: audio!.path!,
        fit: BoxFit.cover,
        dimension: size,
        fallback: icon,
      );
    } else if (audio?.imageUrl != null || audio?.albumArtUrl != null) {
      image = SafeNetworkImage(
        url: audio?.imageUrl ?? audio?.albumArtUrl,
        height: size,
        fit: BoxFit.cover,
        fallBackIcon: icon,
        errorIcon: icon,
      );
    } else {
      image = icon;
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
