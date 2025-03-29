import 'package:flutter/material.dart';

import '../../local_audio/view/local_cover.dart';
import '../data/audio.dart';
import 'audio_fall_back_icon.dart';
import 'safe_network_image.dart';

class AudioTileImage extends StatelessWidget {
  const AudioTileImage({
    super.key,
    this.audio,
    required this.size,
    this.fallback,
  });
  final Audio? audio;
  final double size;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final fallbackIcon = AudioFallBackIcon(audio: audio, iconSize: size / 1.65);
    Widget image;
    if (audio?.hasPathAndId == true) {
      image = LocalCover(
        albumId: audio!.albumId!,
        path: audio!.path!,
        fit: BoxFit.cover,
        dimension: size,
        fallback: fallbackIcon,
      );
    } else {
      image = SafeNetworkImage(
        url: audio?.imageUrl ?? audio?.albumArtUrl,
        height: size,
        fit: BoxFit.cover,
        fallBackIcon: fallbackIcon,
        errorIcon: fallbackIcon,
      );
    }

    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 6),
        child: image,
      ),
    );
  }
}
