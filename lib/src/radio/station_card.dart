import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../theme_data_x.dart';
import 'radio_fall_back_icon.dart';
import 'station_page.dart';

class StationCard extends StatelessWidget {
  const StationCard({
    super.key,
    required this.station,
    required this.startPlaylist,
    required this.isStarredStation,
    required this.unstarStation,
    required this.starStation,
  });

  final Audio? station;
  final Future<void> Function({
    required Set<Audio> audios,
    required String listName,
    int? index,
  }) startPlaylist;
  final bool Function(String name) isStarredStation;
  final void Function(String name) unstarStation;
  final void Function(String name, Set<Audio> audios) starStation;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    return AudioCard(
      color: theme.isLight ? theme.dividerColor : kCardColorDark,
      bottom: AudioCardBottom(text: station?.title?.replaceAll('_', '') ?? ''),
      onPlay: station == null
          ? null
          : () => startPlaylist(
                audios: {station!},
                listName: station!.toShortPath(),
              ),
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
          return StationPage(
            station: station,
            name: station.title ?? station.toString(),
            unStarStation: (s) {
              if (station.url == null) return;
              unstarStation(
                station.url!,
              );
            },
            starStation: (s) {
              if (station.url == null) return;
              starStation(
                station.url!,
                {station},
              );
            },
          );
        },
      ),
    );
  }
}
