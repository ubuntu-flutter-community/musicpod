import '../../common/view/common_widgets.dart';
import '../../common/view/no_search_result_page.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../radio/radio_model.dart';
import '../../radio/view/station_card.dart';
import '../search_model.dart';
import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class SliverRadioSearchResults extends StatelessWidget with WatchItMixin {
  const SliverRadioSearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    final searchResult =
        watchPropertyValue((SearchModel m) => m.radioSearchResult);

    if (searchResult == null || searchResult.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: NoSearchResultPage(
          icons: searchResult == null
              ? const AnimatedEmoji(AnimatedEmojis.drum)
              : const AnimatedEmoji(AnimatedEmojis.rabbit),
          message: Text(
            searchResult == null
                ? context.l10n.search
                : context.l10n.noStationFound,
          ),
        ),
      );
    }

    return SliverGrid.builder(
      gridDelegate: audioCardGridDelegate,
      itemCount: searchResult.length,
      itemBuilder: (context, index) {
        final station = searchResult.elementAt(index);
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
