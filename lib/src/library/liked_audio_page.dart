import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../common/fall_back_header_image.dart';
import '../common/side_bar_fall_back_image.dart';
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
    return SideBarFallBackImage(
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
      controlPanelButton: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          '${likedLocalAudios?.length} ${context.l10n.titles}',
          style: getControlPanelStyle(context.t.textTheme),
        ),
      ),
      noResultMessage: Text(context.l10n.likedSongsSubtitle),
      noResultIcon: const AnimatedEmoji(AnimatedEmojis.twoHearts),
      audios: likedLocalAudios ?? {},
      audioPageType: AudioPageType.likedAudio,
      pageId: kLikedAudiosPageId,
      title: Text(context.l10n.likedSongs),
      headerTitle: context.l10n.likedSongs,
      headerSubtile: context.l10n.likedSongsSubtitle,
      headerLabel: context.l10n.playlist,
      image: FallBackHeaderImage(
        child: Icon(
          Iconz().heart,
          size: 65,
        ),
      ),
    );
  }
}
