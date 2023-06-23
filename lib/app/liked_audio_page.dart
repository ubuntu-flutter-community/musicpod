import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';

class LikedAudioPage extends StatelessWidget {
  const LikedAudioPage({
    super.key,
    this.onArtistTap,
    this.onAlbumTap,
    this.likedAudios,
    required this.showWindowControls,
  });

  static Widget createIcon({
    required BuildContext context,
    required bool selected,
  }) {
    return selected
        ? const Icon(YaruIcons.heart_filled)
        : const Icon(YaruIcons.heart);
  }

  final void Function(String)? onArtistTap;
  final void Function(String)? onAlbumTap;
  final Set<Audio>? likedAudios;
  final bool showWindowControls;

  @override
  Widget build(BuildContext context) {
    return AudioPage(
      onArtistTap: onArtistTap,
      onAlbumTap: onAlbumTap,
      audioPageType: AudioPageType.likedAudio,
      placeTrailer: false,
      showWindowControls: showWindowControls,
      audios: likedAudios,
      pageId: 'likedAudio',
      pageTitle: context.l10n.likedSongs,
      editableName: false,
      deletable: false,
      controlPageButton: const SizedBox.shrink(),
    );
  }
}
