import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/no_search_result_page.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import 'open_radio_discover_page_button.dart';
import 'station_card.dart';

class StarredStationsGrid extends StatelessWidget with WatchItMixin {
  const StarredStationsGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final stations = watchPropertyValue((LibraryModel m) => m.starredStations);
    final length =
        watchPropertyValue((LibraryModel m) => m.starredStationsLength);

    if (length == 0) {
      return SliverNoSearchResultPage(
        message: Column(
          children: [
            Text(context.l10n.noStarredStations),
            const SizedBox(
              height: kLargestSpace,
            ),
            const OpenRadioSearchButton(),
          ],
        ),
        icon: const AnimatedEmoji(AnimatedEmojis.glowingStar),
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
