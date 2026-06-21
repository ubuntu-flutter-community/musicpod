import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/round_image_container.dart';
import '../../extensions/build_context_x.dart';
import '../manager/album_ids_of_artist_manager.dart';
import 'local_cover.dart';

class ArtistImage extends StatelessWidget with WatchItMixin {
  const ArtistImage({required this.artist, required this.dimension});
  final String artist;
  final double dimension;

  @override
  Widget build(BuildContext context) => RoundImageContainer(
    dimension: dimension,
    backgroundColor: context.theme.cardColor,
    images:
        watchValue((AlbumIDsOfArtistManager m) => m.command, param1: artist)
            ?.map(
              (e) => LocalCover(
                albumId: e,
                fallback: ColoredBox(color: context.theme.cardColor),
                fit: BoxFit.fill,
                dimension: dimension,
              ),
            )
            .toList() ??
        [],
    fallBackText: artist,
  );
}
