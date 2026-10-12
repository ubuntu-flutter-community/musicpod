import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/no_search_result_page.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../search/data/search_type.dart';
import '../manager/radio_star_station_manager.dart';
import 'open_radio_discover_page_button.dart';
import 'station_card.dart';

class StarredStationsGrid extends ConsumerWidget {
  const StarredStationsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stations = ref.watch(radioStarStationManagerProvider).value ?? {};
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
