import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/progress.dart';
import '../../common/view/ui_constants.dart';
import '../../radio/radio_model.dart';
import '../../radio/view/radio_reconnect_button.dart';
import '../../radio/view/station_card.dart';
import '../search_model.dart';

class SliverRadioCountryGrid extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const SliverRadioCountryGrid({super.key});

  @override
  State<SliverRadioCountryGrid> createState() => _SliverRadioCountryGridState();
}

class _SliverRadioCountryGridState extends State<SliverRadioCountryGrid> {
  @override
  void initState() {
    super.initState();
    di<SearchModel>().radioCountrySearch();
  }

  @override
  Widget build(BuildContext context) {
    if (watchPropertyValue((RadioModel m) => m.connectedHost) == null) {
      return const Center(child: RadioReconnectButton());
    }

    final Iterable<Audio>? radioSearchResult = watchPropertyValue(
      (SearchModel m) => m.radioCountryChartsPeak?.map(Audio.fromStation),
    );

    if (radioSearchResult == null) {
      return const Center(
        child: Progress(),
      );
    }

    if (radioSearchResult.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: kAudioCardDimension + kAudioCardBottomHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: radioSearchResult.length,
        itemBuilder: (context, index) {
          final station = radioSearchResult.elementAt(index);
          return StationCard(
            uuid: station.uuid!,
          );
        },
        separatorBuilder: (context, index) =>
            const SizedBox(width: kMediumSpace),
      ),
    );
  }
}
