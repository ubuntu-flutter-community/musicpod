import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/no_search_result_page.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../radio_manager.dart';
import '../../search/search_type.dart';
import 'open_radio_discover_page_button.dart';
import 'station_card.dart';

class StarredStationsGrid extends StatelessWidget with WatchItMixin {
  const StarredStationsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final stations = watchValue((RadioManager m) => m.toggleStarStationCommand);
    final length = stations.length;

    if (length == 0) {
      return SliverNoSearchResultPage(
        message: Column(
          children: [
            Text(context.l10n.noStarredStations),
            const SizedBox(height: kLargestSpace),
            const OpenRadioSearchButton(searchType: SearchType.radioName),
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
