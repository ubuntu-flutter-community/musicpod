import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';

import 'package:yaru/yaru.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../get.dart';
import '../../globals.dart';
import '../../l10n.dart';
import '../../library.dart';
import '../../player.dart';
import '../../radio.dart';
import '../../theme.dart';
import 'open_radio_discover_page_button.dart';
import 'radio_history_list.dart';
import 'station_card.dart';

class RadioLibPage extends StatelessWidget with WatchItMixin {
  const RadioLibPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final radioCollectionView =
        watchPropertyValue((RadioModel m) => m.radioCollectionView);
    final radioModel = getIt<RadioModel>();

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: kYaruPagePadding,
            ),
            YaruChoiceChipBar(
              chipBackgroundColor: chipColor(theme),
              selectedChipBackgroundColor: chipSelectionColor(theme, false),
              borderColor: chipBorder(theme, false),
              selectedFirst: false,
              clearOnSelect: false,
              onSelected: (index) => radioModel
                  .setRadioCollectionView(RadioCollectionView.values[index]),
              yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
              labels: [
                Text(context.l10n.station),
                Text(context.l10n.tags),
                Text(context.l10n.hearingHistory),
              ],
              isSelected: RadioCollectionView.values
                  .map((e) => e == radioCollectionView)
                  .toList(),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Expanded(
          child: switch (radioCollectionView) {
            RadioCollectionView.stations => const StationGrid(),
            RadioCollectionView.tags => const TagGrid(),
            RadioCollectionView.history => const RadioHistoryList(),
          },
        ),
      ],
    );
  }
}

class StationGrid extends StatelessWidget with WatchItMixin {
  const StationGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final stations = watchPropertyValue((LibraryModel m) => m.starredStations);
    final length =
        watchPropertyValue((LibraryModel m) => m.starredStationsLength);
    final libraryModel = getIt<LibraryModel>();
    final playerModel = getIt<PlayerModel>();

    if (length == 0) {
      return NoSearchResultPage(
        message: Column(
          children: [
            Text(context.l10n.noStarredStations),
            const SizedBox(
              height: kYaruPagePadding,
            ),
            const OpenRadioDiscoverPageButton(),
          ],
        ),
        icons: const AnimatedEmoji(AnimatedEmojis.glowingStar),
      );
    }

    return GridView.builder(
      padding: gridPadding,
      gridDelegate: audioCardGridDelegate,
      itemCount: length,
      itemBuilder: (context, index) {
        final station = stations.entries.elementAt(index).value.firstOrNull;
        return StationCard(
          station: station,
          startPlaylist: playerModel.startPlaylist,
          isStarredStation: libraryModel.isStarredStation,
          unstarStation: libraryModel.unStarStation,
          starStation: libraryModel.addStarredStation,
        );
      },
    );
  }
}

class TagGrid extends StatelessWidget with WatchItMixin {
  const TagGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final favTagsLength =
        watchPropertyValue((LibraryModel m) => m.favTags.length);
    final favTags = watchPropertyValue((LibraryModel m) => m.favTags);

    if (favTagsLength == 0) {
      return NoSearchResultPage(
        message: Column(
          children: [
            Text(context.l10n.noStarredTags),
            const SizedBox(
              height: kYaruPagePadding,
            ),
            const OpenRadioDiscoverPageButton(),
          ],
        ),
        icons: const AnimatedEmoji(AnimatedEmojis.glowingStar),
      );
    }

    return GridView.builder(
      padding: gridPadding,
      gridDelegate: audioCardGridDelegate,
      itemCount: favTagsLength,
      itemBuilder: (context, index) {
        final tag = favTags.elementAt(index);
        return AudioCard(
          image: SideBarFallBackImage(
            color: getAlphabetColor(tag),
            width: double.infinity,
            height: double.infinity,
            child: Icon(
              getIconForTag(tag),
              size: 65,
            ),
          ),
          bottom: AudioCardBottom(text: tag),
          onTap: () {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) {
                  return RadioSearchPage(
                    searchQuery: tag,
                    radioSearch: RadioSearch.tag,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
