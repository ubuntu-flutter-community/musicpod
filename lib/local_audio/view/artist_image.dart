import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/theme.dart';

import '../../common/data/audio.dart';
import '../../common/view/round_image_container.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../local_audio_model.dart';
import 'local_cover.dart';

class ArtistImage extends StatefulWidget {
  const ArtistImage({
    super.key,
    required this.artist,
    this.dimension,
  });

  final String artist;
  final double? dimension;

  @override
  State<ArtistImage> createState() => _ArtistImageState();
}

class _ArtistImageState extends State<ArtistImage> {
  late Future<List<Audio>?> _artistAudios;

  @override
  void initState() {
    super.initState();
    final model = di<LocalAudioModel>();
    final cachedTitlesOfArtist = model.getCachedTitlesOfArtist(widget.artist);
    _artistAudios = cachedTitlesOfArtist != null
        ? Future.value(cachedTitlesOfArtist)
        : model.findTitlesOfArtist(widget.artist);
  }

  @override
  Widget build(BuildContext context) {
    final model = di<LocalAudioModel>();

    if (model.getCachedTitlesOfArtist(widget.artist) != null) {
      return _ArtistImage(
        artist: widget.artist,
        artistAudios: model.getCachedTitlesOfArtist(widget.artist)!,
        dimension: widget.dimension,
      );
    }

    return FutureBuilder(
      future: _artistAudios,
      builder: (context, snapshot) {
        final artistAudios = snapshot.data ?? [];
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: artistAudios.isEmpty ? 0 : 1,
          child: _ArtistImage(
            artistAudios: artistAudios,
            dimension: widget.dimension,
            artist: widget.artist,
          ),
        );
      },
    );
  }
}

class _ArtistImage extends StatelessWidget {
  const _ArtistImage({
    required this.artist,
    required this.artistAudios,
    this.dimension,
  });
  final String artist;
  final List<Audio> artistAudios;
  final double? dimension;

  @override
  Widget build(BuildContext context) {
    return RoundImageContainer(
      backgroundColor: artistAudios.isEmpty
          ? getAlphabetColor(artist).scale(saturation: -0.6)
          : Colors.transparent,
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
                  dimension: dimension,
                ),
              )
              .toList(),
      fallBackText: artist,
    );
  }
}
