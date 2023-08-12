import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/audio_page_body.dart';
import 'package:musicpod/app/local_audio/shop_recommendations.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/utils.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class TitlesView extends StatelessWidget {
  const TitlesView({
    super.key,
    required this.audios,
    required this.showWindowControls,
    this.onTextTap,
  });

  final Set<Audio>? audios;
  final bool showWindowControls;
  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;

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
      noResultMessage: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.noLocalTitlesFound),
          const ShopRecommendations()
        ],
      ),
      audios: Set.from(sortedAudios),
      audioPageType: AudioPageType.immutable,
      pageId: context.l10n.localAudio,
      editableName: false,
      showAudioPageHeader: false,
      sort: true,
      audioFilter: AudioFilter.album,
      showTrack: true,
      onTextTap: onTextTap,
    );
  }
}
