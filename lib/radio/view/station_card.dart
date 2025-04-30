import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/view/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/audio_fall_back_icon.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/theme.dart';
import '../../player/player_model.dart';
import '../radio_model.dart';
import 'station_page.dart';

class StationCard extends StatefulWidget {
  const StationCard({super.key, required this.uuid});

  final String uuid;

  @override
  State<StationCard> createState() => _StationCardState();
}

class _StationCardState extends State<StationCard> {
  late Future<Audio?> _station;

  @override
  void initState() {
    super.initState();
    _station = di<RadioModel>().getStationByUUID(widget.uuid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _station,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const NoSearchResultPage();
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: Progress(),
          );
        }

        final station = snapshot.data!;

        return AudioCard(
          bottom:
              AudioCardBottom(text: station.title?.replaceAll('_', '') ?? ''),
          onPlay: station.uuid == null
              ? null
              : () => di<PlayerModel>().startPlaylist(
                    audios: [station],
                    listName: widget.uuid,
                  ).then((_) => di<RadioModel>().clickStation(station)),
          onTap: station.uuid == null
              ? null
              : () => di<RoutingManager>().push(
                    builder: (_) => StationPage(uuid: widget.uuid),
                    pageId: widget.uuid,
                  ),
          image: SizedBox.expand(
            child: SafeNetworkImage(
              fallBackIcon: AudioFallBackIcon(
                audio: station,
                iconSize: 70,
              ),
              errorIcon: AudioFallBackIcon(
                audio: station,
                iconSize: 70,
              ),
              url: station.imageUrl,
              fit: BoxFit.scaleDown,
              height: audioCardDimension,
              width: audioCardDimension,
            ),
          ),
        );
      },
    );
  }
}
