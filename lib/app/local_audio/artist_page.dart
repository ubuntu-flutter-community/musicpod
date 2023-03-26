import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/image_grid.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';

class ArtistPage extends StatelessWidget {
  const ArtistPage({
    super.key,
    required this.images,
    required this.artistAudios,
    required this.showWindowControls,
    this.onArtistTap,
    this.onAlbumTap,
  });

  final Set<Uint8List>? images;
  final Set<Audio>? artistAudios;
  final bool showWindowControls;

  final void Function(String artist)? onArtistTap;
  final void Function(String album)? onAlbumTap;

  @override
  Widget build(BuildContext context) {
    return AudioPage(
      onAlbumTap: onAlbumTap,
      onArtistTap: onArtistTap,
      audioFilter: AudioFilter.album,
      audioPageType: AudioPageType.artist,
      pageLabel: context.l10n.artist,
      pageTitle: artistAudios?.firstOrNull?.artist,
      image: images != null && images!.length >= 4
          ? ImageGrid(images: images)
          : images?.isNotEmpty == true
              ? Image.memory(
                  images!.first,
                  width: 200.0,
                  fit: BoxFit.fitWidth,
                  filterQuality: FilterQuality.medium,
                )
              : const SizedBox.shrink(),
      pageSubtile: artistAudios?.firstOrNull?.genre,
      placeTrailer: images?.isNotEmpty == true,
      controlPageButton: const SizedBox.shrink(),
      showWindowControls: showWindowControls,
      deletable: false,
      audios: artistAudios,
      pageId: artistAudios?.firstOrNull?.artist ?? artistAudios.toString(),
      editableName: false,
    );
  }
}
