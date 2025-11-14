import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/round_image_container.dart';
import '../../extensions/build_context_x.dart';
import '../local_audio_model.dart';
import 'local_cover.dart';

class ArtistImage extends StatefulWidget {
  const ArtistImage({super.key, required this.artist, this.dimension});

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

    final cachedTitlesOfArtist = model.getCachedTitlesOfArtist(widget.artist);
    if (cachedTitlesOfArtist != null) {
      return _ArtistImage(
        artist: widget.artist,
        artistAudios: cachedTitlesOfArtist,
        dimension: widget.dimension,
      );
    }

    return FutureBuilder(
      future: _artistAudios,
      builder: (context, snapshot) => _ArtistImage(
        artistAudios: snapshot.data ?? [],
        dimension: widget.dimension,
        artist: widget.artist,
      ),
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
    final theme = context.theme;
    return RoundImageContainer(
      dimension: dimension,
      backgroundColor: theme.cardColor,
      images: artistAudios.isEmpty
          ? []
          : di<LocalAudioModel>()
                .findUniqueAlbumAudios(artistAudios)
                .where((e) => e.albumId != null && e.path != null)
                .map(
                  (e) => LocalCover(
                    albumId: e.albumId!,
                    path: e.path!,
                    fallback: ColoredBox(color: theme.cardColor),
                    fit: BoxFit.cover,
                    dimension: dimension,
                  ),
                )
                .toList(),
      fallBackText: artist,
    );
  }
}
