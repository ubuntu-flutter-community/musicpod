import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/connectivity_model.dart';
import '../../common/data/audio.dart';
import '../../common/view/loading_grid.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/theme.dart';
import '../../player/player_model.dart';
import '../../radio/radio_model.dart';
import '../../radio/view/radio_reconnect_button.dart';
import '../../radio/view/station_card.dart';
import '../search_model.dart';

class SliverRadioCountryGrid extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const SliverRadioCountryGrid({super.key, this.limit = 3});

  final int limit;

  @override
  State<SliverRadioCountryGrid> createState() => _SliverRadioCountryGridState();
}

class _SliverRadioCountryGridState extends State<SliverRadioCountryGrid> {
  @override
  void initState() {
    super.initState();
    di<SearchModel>().radioCountrySearch(limit: widget.limit);
  }

  @override
  Widget build(BuildContext context) {
    if (!watchPropertyValue((ConnectivityModel m) => m.isOnline)) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: OfflineBody(),
      );
    }

    if (watchPropertyValue((RadioModel m) => m.connectedHost) == null) {
      return const SliverToBoxAdapter(
        child: Center(child: RadioReconnectButton()),
      );
    }

    Iterable<Audio>? radioSearchResult = watchPropertyValue(
      (SearchModel m) => m.countryCharts?.map(Audio.fromStation),
    );

    if (radioSearchResult == null) {
      return SliverLoadingGrid(limit: widget.limit);
    }

    if (radioSearchResult.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    return SliverGrid.builder(
      gridDelegate: audioCardGridDelegate,
      itemCount: radioSearchResult.length,
      itemBuilder: (context, index) {
        final station = radioSearchResult.elementAt(index);
        return StationCard(
          station: station,
          startPlaylist: ({
            required audios,
            index,
            required listName,
          }) {
            return di<PlayerModel>()
                .startPlaylist(
                  audios: audios,
                  listName: listName,
                )
                .then((_) => di<RadioModel>().clickStation(station));
          },
        );
      },
    );
  }
}
