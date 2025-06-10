import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/view/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/page_ids.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/sliver_audio_tile_list.dart';
import '../../common/view/sliver_fill_remaining_progress.dart';
import '../local_audio_model.dart';
import 'artist_page.dart';

class TitlesView extends StatelessWidget with WatchItMixin {
  const TitlesView({
    super.key,
    required this.audios,
    this.noResultMessage,
    this.noResultIcon,
    this.constraints,
  });

  final List<Audio>? audios;
  final Widget? noResultMessage, noResultIcon;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final importing = watchPropertyValue((LocalAudioModel m) => m.importing);

    if (audios == null || importing) {
      return const SliverFillRemainingProgress();
    }

    if (audios!.isEmpty) {
      return SliverNoSearchResultPage(
        icon: noResultIcon,
        message: noResultMessage,
      );
    }

    return SliverAudioTileList(
      constraints: constraints,
      audios: audios!,
      audioPageType: AudioPageType.allTitlesView,
      pageId: PageIDs.localAudio,
      onSubTitleTab: (artist) => di<RoutingManager>().push(
        builder: (_) => ArtistPage(pageId: artist),
        pageId: artist,
      ),
    );
  }
}
