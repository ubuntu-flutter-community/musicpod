import '../../common/data/audio.dart';
import '../../common/view/cover_background.dart';
import '../../common/view/round_image_container.dart';
import '../local_audio_model.dart';
import 'local_cover.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class ArtistRoundImageContainer extends StatelessWidget {
  const ArtistRoundImageContainer({
    super.key,
    required this.artistAudios,
  });

  final List<Audio>? artistAudios;

  @override
  Widget build(BuildContext context) {
    return RoundImageContainer(
      images: artistAudios == null
          ? []
          : di<LocalAudioModel>()
              .findUniqueAlbumAudios(artistAudios!)
              .where(
                (e) => e.albumId != null && e.path != null,
              )
              .map(
                (e) => LocalCover(
                  albumId: e.albumId!,
                  path: e.path!,
                  fallback: const CoverBackground(),
                  fit: BoxFit.cover,
                ),
              )
              .toList(),
      fallBackText: artistAudios?.firstOrNull?.artist ?? 'a',
    );
  }
}
