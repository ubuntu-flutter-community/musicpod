import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';

class LikedAudioPage extends StatelessWidget {
  const LikedAudioPage({
    super.key,
    this.onArtistTap,
    this.onAlbumTap,
    this.likedAudios,
    required this.showWindowControls,
  });

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
