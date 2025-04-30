import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/theme.dart';

import '../../common/data/audio.dart';
import '../../common/view/round_image_container.dart';
import '../../extensions/build_context_x.dart';
import '../local_audio_model.dart';
import 'local_cover.dart';

class ArtistRoundImageContainer extends StatefulWidget {
  const ArtistRoundImageContainer({
    super.key,
    required this.artist,
    this.dimension,
  });

  final String artist;
  final double? dimension;

  @override
  State<ArtistRoundImageContainer> createState() =>
      _ArtistRoundImageContainerState();
}

class _ArtistRoundImageContainerState extends State<ArtistRoundImageContainer> {
  late Future<List<Audio>?> _artistAudios;

  @override
  void initState() {
    super.initState();
    _artistAudios = di<LocalAudioModel>().findTitlesOfArtist(widget.artist);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _artistAudios,
      builder: (context, snapshot) {
        final artistAudios = snapshot.data ?? [];
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: artistAudios.isEmpty ? 0 : 1,
          child: RoundImageContainer(
            backgroundColor: context.theme.cardTheme.color,
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
                        fallback: ColoredBox(
                          color: context.colorScheme.onSurface.scale(
                            lightness: -0.99,
                          ),
                        ),
                        fit: BoxFit.cover,
                        dimension: widget.dimension,
                      ),
                    )
                    .toList(),
            fallBackText: widget.artist,
          ),
        );
      },
    );
  }
}
