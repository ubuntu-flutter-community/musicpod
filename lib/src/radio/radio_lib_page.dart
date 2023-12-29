import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common.dart';
import '../../data.dart';
import '../../l10n.dart';
import '../../library.dart';
import 'station_card.dart';

class RadioLibPage extends StatelessWidget {
  const RadioLibPage({
    super.key,
    required this.startPlaylist,
    this.onTextTap,
    required this.isStarredStation,
    required this.unstarStation,
    required this.starStation,
    required this.isOnline,
  });

  final Future<void> Function({
    required Set<Audio> audios,
    required String listName,
    int? index,
  }) startPlaylist;
  final bool Function(String name) isStarredStation;
  final void Function(String text)? onTextTap;
  final void Function(String name) unstarStation;
  final void Function(String name, Set<Audio> audios) starStation;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final stations = context.select((LibraryModel m) => m.starredStations);
    final length = context.select((LibraryModel m) => m.starredStationsLength);

    if (!isOnline) {
      return const OfflinePage();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: length == 0
          ? NoSearchResultPage(
              message: Text(context.l10n.noStarredStations),
            )
          : GridView.builder(
              padding: gridPadding,
              gridDelegate: imageGridDelegate,
              itemCount: length,
              itemBuilder: (context, index) {
                final station =
                    stations.entries.elementAt(index).value.firstOrNull;
                return StationCard(
                  station: station,
                  startPlaylist: startPlaylist,
                  isStarredStation: isStarredStation,
                  onTextTap: onTextTap,
                  unstarStation: unstarStation,
                  starStation: starStation,
                );
              },
            ),
    );
  }
}
