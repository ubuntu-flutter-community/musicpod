import 'package:flutter/material.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import 'radio_page.dart';
import 'station_page.dart';

class StationCard extends StatelessWidget {
  const StationCard({
    super.key,
    required this.station,
    required this.play,
    required this.isStarredStation,
    required this.onTextTap,
    required this.unstarStation,
    required this.starStation,
  });

  final Audio? station;
  final Future<void> Function({Duration? newPosition, Audio? newAudio}) play;
  final bool Function(String name) isStarredStation;
  final void Function(String text)? onTextTap;
  final void Function(String name) unstarStation;
  final void Function(String name, Set<Audio> audios) starStation;

  @override
  Widget build(BuildContext context) {
    return AudioCard(
      bottom: AudioCardBottom(text: station?.title?.replaceAll('_', '') ?? ''),
      onPlay: () => play(newAudio: station),
      onTap: station == null ? null : () => onTap(context, station!),
      image: SizedBox.expand(
        child: SafeNetworkImage(
          fallBackIcon: RadioFallBackIcon(
            station: station,
          ),
          errorIcon: RadioFallBackIcon(station: station),
          url: station?.imageUrl,
          fit: BoxFit.scaleDown,
          height: kSmallCardHeight,
          width: kSmallCardHeight,
        ),
      ),
    );
  }

  void onTap(BuildContext context, Audio station) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final starred = isStarredStation(
            station.title ?? station.toString(),
          );
          return StationPage(
            onTextTap: (v) => onTextTap?.call(v),
            station: station,
            name: station.title ?? station.toString(),
            unStarStation: (s) => unstarStation(
              station.title ?? station.toString(),
            ),
            starStation: (s) => starStation(
              station.title ?? station.toString(),
              {station},
            ),
            play: play,
            isStarred: starred,
          );
        },
      ),
    );
  }
}
