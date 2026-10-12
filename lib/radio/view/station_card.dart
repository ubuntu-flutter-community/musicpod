import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data/play_anywhere_param.dart';
import '../../app/play_anywhere_manager.dart';
import '../../app/routing_manager.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../player/manager/current_audio_manager.dart';
import '../../player/manager/play_pause_manager.dart';
import '../manager/station_manager.dart';
import 'station_page_icon.dart';
import 'station_title.dart';

class StationCard extends ConsumerWidget {
  const StationCard({super.key, required this.uuid});

  final String uuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(
      currentAudioManagerProvider.select((a) => a?.uuid == uuid),
    );
    final isPlayerPlaying = ref.watch(playPauseManagerProvider);

    final stationResult = ref.watch(stationManagerProvider(uuid));

    if (stationResult.hasError) {
      return AudioCard(
        image: Center(child: Icon(Iconz.imageMissing, size: 70)),
      );
    }

    final station = stationResult.value;
    if (station == null) return const AudioCard();

    final iconData = isSelected && isPlayerPlaying
        ? Iconz.pause
        : Iconz.playFilled;

    return AudioCard(
      bottom: AudioCardBottom(child: StationTitle(uuid: uuid)),
      playIcon: iconData,
      seleted: isSelected,
      onPlay: () => ref
          .read(playAnywhereManagerProvider.notifier)
          .play(
            PlayAnywhereParam(pageId: uuid, audioPageType: AudioPageType.radio),
          ),
      onTap: () => ref.read(routingManagerProvider.notifier).push(pageId: uuid),
      image: SizedBox.expand(
        child: StationPageIcon(
          uuid: uuid,
          selected: isSelected,
          dimension: audioCardDimension,
        ),
      ),
    );
  }
}
