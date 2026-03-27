import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/routing_manager.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/audio_fall_back_icon.dart';
import '../../common/view/icons.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/theme.dart';
import '../../player/player_model.dart';
import '../radio_model.dart';
import 'station_page.dart';

class StationCard extends StatelessWidget with WatchItMixin {
  const StationCard({super.key, required this.uuid});

  final String uuid;

  @override
  Widget build(BuildContext context) {
    callOnceAfterThisBuild(
      (_) => di<RadioManager>().getStationByUUIDCommand(uuid).run(),
    );

    final isSelected = watchPropertyValue(
      (PlayerModel m) => m.audio?.uuid == uuid,
    );
    final isPlayerPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);

    final stationResult = watchValue(
      (RadioManager m) => m.getStationByUUIDCommand(uuid).results,
    );
    final station = stationResult.data;
    final error = stationResult.error;

    if (error != null) return AudioCard(image: Icon(Iconz.imageMissing));

    if (station == null) return const AudioCard();

    final iconData = isSelected && isPlayerPlaying
        ? Iconz.pause
        : Iconz.playFilled;

    return AudioCard(
      bottom: AudioCardBottom(text: station.title?.replaceAll('_', '') ?? ''),
      playIcon: iconData,
      seleted: isSelected,
      onPlay: station.uuid == null
          ? null
          : () {
              if (isSelected) {
                di<PlayerModel>().playOrPause();
                return;
              }
              di<PlayerModel>()
                  .startPlaylist(audios: [station], listName: uuid)
                  .then((_) => di<RadioManager>().clickStation(station));
            },
      onTap: station.uuid == null
          ? null
          : () => di<RoutingManager>().push(
              builder: (_) => StationPage(uuid: uuid),
              pageId: uuid,
            ),
      image: SizedBox.expand(
        child: SafeNetworkImage(
          fallBackIcon: AudioFallBackIcon(audio: station, iconSize: 70),
          errorIcon: AudioFallBackIcon(audio: station, iconSize: 70),
          url: station.imageUrl,
          fit: BoxFit.scaleDown,
          height: audioCardDimension,
          width: audioCardDimension,
        ),
      ),
    );
  }
}
