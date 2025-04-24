import '../../common/data/audio.dart';
import '../../common/view/cover_background.dart';
import '../../common/view/round_image_container.dart';
import '../local_audio_model.dart';
import 'local_cover.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class ArtistRoundImageContainer extends StatefulWidget {
  const ArtistRoundImageContainer({
    super.key,
    required this.artist,
    this.height,
    this.width,
  });

  final String artist;
  final double? height, width;

  @override
  State<ArtistRoundImageContainer> createState() =>
      _ArtistRoundImageContainerState();
}

class _ArtistRoundImageContainerState extends State<ArtistRoundImageContainer> {
  late List<Audio> artistAudios;

  @override
  void initState() {
    super.initState();
    artistAudios =
        di<LocalAudioModel>().findTitlesOfArtist(widget.artist) ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return RoundImageContainer(
      images: artistAudios.isEmpty
          ? []
          : di<LocalAudioModel>()
              .findUniqueAlbumAudios(artistAudios)
              .where(
                (e) => e.albumId != null && e.path != null,
              )
              .map(
                (e) => LocalCover(
                  albumId: e.albumId!,
                  path: e.path!,
                  fallback: const CoverBackground(),
                  fit: BoxFit.cover,
                  height: widget.height,
                  width: widget.width,
                ),
              )
              .toList(),
      fallBackText: widget.artist,
    );
  }
}
