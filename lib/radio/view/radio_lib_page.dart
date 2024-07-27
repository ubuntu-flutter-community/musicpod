import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/icons.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
import '../radio_model.dart';
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
    final radioModel = di<RadioModel>();

    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: YaruChoiceChipBar(
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
          ),
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
    final playerModel = di<PlayerModel>();

    if (length == 0) {
      return NoSearchResultPage(
        message: Column(
          children: [
            Text(context.l10n.noStarredStations),
            const SizedBox(
              height: kYaruPagePadding,
            ),
            const OpenRadioSearchButton(),
          ],
        ),
        icon: const AnimatedEmoji(AnimatedEmojis.glowingStar),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: getAdaptiveHorizontalPadding(constraints),
          gridDelegate: audioCardGridDelegate,
          itemCount: length,
          itemBuilder: (context, index) {
            final station = stations.entries.elementAt(index).value.firstOrNull;
            return StationCard(
              station: station,
              startPlaylist: playerModel.startPlaylist,
            );
          },
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
        watchPropertyValue((LibraryModel m) => m.favRadioTags.length);
    final favTags = watchPropertyValue((LibraryModel m) => m.favRadioTags);

    if (favTagsLength == 0) {
      return NoSearchResultPage(
        message: Column(
          children: [
            Text(context.l10n.noStarredTags),
            const SizedBox(
              height: kYaruPagePadding,
            ),
            const OpenRadioSearchButton(),
          ],
        ),
        icon: const AnimatedEmoji(AnimatedEmojis.glowingStar),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: getAdaptiveHorizontalPadding(constraints),
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
                di<LibraryModel>().pushNamed(kSearchPageId);
                di<SearchModel>()
                  ..setTag(Tag(name: tag.toLowerCase(), stationCount: 1))
                  ..setAudioType(AudioType.radio)
                  ..search();
              },
            );
          },
        );
      },
    );
  }
}
