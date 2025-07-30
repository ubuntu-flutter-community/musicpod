import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/no_search_result_page.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../radio_model.dart';
import 'open_radio_discover_page_button.dart';
import 'radio_reconnect_button.dart';
import 'station_card.dart';

class StarredStationsGrid extends StatelessWidget with WatchItMixin {
  const StarredStationsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    if (watchPropertyValue((RadioModel m) => m.connectedHost) == null) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: RadioReconnectButton()),
      );
    }

    final stations = watchPropertyValue((LibraryModel m) => m.starredStations);
    final length = watchPropertyValue(
      (LibraryModel m) => m.starredStationsLength,
    );

    if (length == 0) {
      return SliverNoSearchResultPage(
        message: Column(
          children: [
            Text(context.l10n.noStarredStations),
            const SizedBox(height: kLargestSpace),
            const OpenRadioSearchButton(),
          ],
        ),
      );
    }

    return SliverGrid.builder(
      gridDelegate: audioCardGridDelegate,
      itemCount: length,
      itemBuilder: (context, index) {
        final uuid = stations.elementAt(index);
        return StationCard(key: ValueKey(uuid), uuid: uuid);
      },
    );
  }
}
