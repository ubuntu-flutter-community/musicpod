import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/no_search_result_page.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/theme.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../radio/radio_model.dart';
import '../../radio/view/station_card.dart';
import '../search_model.dart';

class SliverRadioSearchResults extends StatelessWidget with WatchItMixin {
  const SliverRadioSearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((PlayerModel m) => m.isOnline);

    if (!isOnline) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: OfflineBody(),
      );
    }
    final radioSearchResult =
        watchPropertyValue((SearchModel m) => m.radioSearchResult);
    final searchQuery = watchPropertyValue((SearchModel m) => m.searchQuery);
    final searchType = watchPropertyValue((SearchModel m) => m.searchType);
    final loading = watchPropertyValue((SearchModel m) => m.loading);

    if (radioSearchResult == null ||
        (searchQuery?.isEmpty == true && radioSearchResult.isEmpty == true)) {
      return SliverFillNoSearchResultPage(
        icon: const AnimatedEmoji(AnimatedEmojis.drum),
        message:
            Text('${context.l10n.search} ${searchType.localize(context.l10n)}'),
      );
    }

    if (radioSearchResult.isEmpty && !loading) {
      return SliverFillNoSearchResultPage(
        icon: const AnimatedEmoji(AnimatedEmojis.rabbit),
        message: Text(context.l10n.noStationFound),
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
