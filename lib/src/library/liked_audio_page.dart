import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../l10n/l10n.dart';

class LikedAudioPage extends StatelessWidget {
  const LikedAudioPage({
    super.key,
    this.onTextTap,
    this.likedLocalAudios,
  });

  static Widget createIcon({
    required BuildContext context,
    required bool selected,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.t.colorScheme.primary
                .scale(lightness: 0.1)
                .withOpacity(0.4),
            context.t.colorScheme.primary
                .scale(lightness: 0.6)
                .withOpacity(0.4),
          ],
        ),
      ),
      width: sideBarImageSize,
      height: sideBarImageSize,
      child: selected ? Icon(Iconz().heartFilled) : Icon(Iconz().heart),
    );
  }

  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;
  final Set<Audio>? likedLocalAudios;
  // final Set<Audio>? likedPodcasts;

  @override
  Widget build(BuildContext context) {
    return AudioPage(
      showTrack: false,
      noResultMessage: Text(context.l10n.likedSongsSubtitle),
      noResultIcon: const AnimatedEmoji(AnimatedEmojis.twoHearts),
      audios: likedLocalAudios ?? {},
      audioPageType: AudioPageType.likedAudio,
      pageId: kLikedAudios,
      title: Text(context.l10n.likedSongs),
      headerTitle: context.l10n.likedSongs,
      headerSubtile: context.l10n.likedSongsSubtitle,
      headerLabel: context.l10n.playlist,
      image: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.t.colorScheme.primary
                  .scale(lightness: 0.1)
                  .withOpacity(0.4),
              context.t.colorScheme.primary
                  .scale(lightness: 0.6)
                  .withOpacity(0.4),
            ],
          ),
        ),
        width: 200,
        height: 200,
        child: Icon(
          Iconz().heart,
          size: 65,
        ),
      ),
    );
  }
}
