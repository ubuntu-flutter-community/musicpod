import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/data/play_anywhere_param.dart';
import '../../app/play_anywhere_manager.dart';
import '../../app/routing_manager.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/audio_fall_back_icon.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/icons.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/theme.dart';
import '../../player/manager/player_manager.dart';
import '../manager/station_manager.dart';

class StationCard extends StatelessWidget with WatchItMixin {
  const StationCard({super.key, required this.uuid});

  final String uuid;

  @override
  Widget build(BuildContext context) {
    final isSelected = watchPropertyValue(
      (PlayerManager m) => m.audio?.uuid == uuid,
    );
    final isPlayerPlaying = watchPropertyValue(
      (PlayerManager m) => m.isPlaying,
    );

    final stationResult = watchValue(
      (StationManager m) => m.command.results,
      param1: uuid,
    );

    final station = stationResult.data;
    final error = stationResult.error;

    if (error != null)
      return AudioCard(
        image: Center(child: Icon(Iconz.imageMissing, size: 70)),
      );

    if (station == null) return const AudioCard();

    final iconData = isSelected && isPlayerPlaying
        ? Iconz.pause
        : Iconz.playFilled;

    return AudioCard(
      bottom: AudioCardBottom(text: station.title?.replaceAll('_', '') ?? ''),
      playIcon: iconData,
      seleted: isSelected,
      onPlay: () => di<PlayAnywhereManager>().command.run(
        PlayAnywhereParam(pageId: uuid, audioPageType: AudioPageType.radio),
      ),
      onTap: () => di<RoutingManager>().push(pageId: uuid),
      image: SizedBox.expand(
        child: SafeNetworkImage(
          fallbackWidget: AudioFallBackIcon(audio: station, iconSize: 70),
          errorWidget: AudioFallBackIcon(audio: station, iconSize: 70),
          url: station.imageUrl,
          fit: BoxFit.scaleDown,
          height: audioCardDimension,
          width: audioCardDimension,
        ),
      ),
    );
  }
}
