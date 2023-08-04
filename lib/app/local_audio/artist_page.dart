import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/image_grid.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ArtistPage extends StatelessWidget {
  const ArtistPage({
    super.key,
    required this.images,
    required this.artistAudios,
    required this.showWindowControls,
    this.onTextTap,
  });

  final Set<Uint8List>? images;
  final Set<Audio>? artistAudios;
  final bool showWindowControls;

  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;

  @override
  Widget build(BuildContext context) {
    return AudioPage(
      onTextTap: onTextTap,
      audioFilter: AudioFilter.album,
      audioPageType: AudioPageType.artist,
      pageLabel: context.l10n.artist,
      pageTitle: artistAudios?.firstOrNull?.artist,
      image: ArtistImage(images: images),
      pageSubtile: artistAudios?.firstOrNull?.genre,
      controlPageButton: const SizedBox.shrink(),
      deletable: false,
      audios: artistAudios,
      pageId: artistAudios?.firstOrNull?.artist ?? artistAudios.toString(),
      editableName: false,
    );
  }
}

class ArtistImage extends StatelessWidget {
  const ArtistImage({super.key, this.images});

  final Set<Uint8List>? images;

  @override
  Widget build(BuildContext context) {
    if (images?.isNotEmpty == true) {
      if (images!.length >= 4) {
        return ImageGrid(images: images);
      } else if (images!.length >= 2) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: MemoryImage(images!.first),
            ),
          ),
          child: YaruClip.diagonal(
            position: YaruDiagonalClip.bottomLeft,
            child: Image.memory(
              images!.elementAt(1),
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.medium,
            ),
          ),
        );
      } else {
        return Image.memory(
          images!.first,
          width: 200.0,
          fit: BoxFit.fitWidth,
          filterQuality: FilterQuality.medium,
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
