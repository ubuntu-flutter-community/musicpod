import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/audio_page_body.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/utils.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class TitlesView extends StatelessWidget {
  const TitlesView({
    super.key,
    required this.audios,
    required this.showWindowControls,
    this.onArtistTap,
    this.onAlbumTap,
  });

  final Set<Audio>? audios;
  final bool showWindowControls;
  final void Function(String artist)? onArtistTap;
  final void Function(String album)? onAlbumTap;

  @override
  Widget build(BuildContext context) {
    if (audios == null) {
      return const Center(
        child: YaruCircularProgressIndicator(),
      );
    }

    final sortedAudios = audios!.toList();

    sortListByAudioFilter(
      audioFilter: AudioFilter.album,
      audios: sortedAudios,
    );

    return AudioPageBody(
      audios: Set.from(sortedAudios),
      audioPageType: AudioPageType.immutable,
      pageId: 'localAudio',
      editableName: false,
      showAudioPageHeader: false,
      sort: true,
      audioFilter: AudioFilter.album,
      showTrack: true,
      showWindowControls: showWindowControls,
      onAlbumTap: onArtistTap,
      onArtistTap: onArtistTap,
    );
  }
}
