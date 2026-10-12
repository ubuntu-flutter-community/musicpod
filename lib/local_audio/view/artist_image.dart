import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/round_image_container.dart';
import '../../extensions/build_context_x.dart';
import '../manager/album_ids_of_artist_manager.dart';
import 'local_cover.dart';

class ArtistImage extends ConsumerWidget {
  const ArtistImage({super.key, required this.artist, required this.dimension});
  final String artist;
  final double dimension;

  @override
  Widget build(BuildContext context, WidgetRef ref) => RoundImageContainer(
    dimension: dimension,
    backgroundColor: context.theme.cardColor,
    images:
        ref
            .watch(albumIDsOfArtistManagerProvider(artist))
            .value
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
