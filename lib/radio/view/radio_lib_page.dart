import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
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
        // TODO: port to sliver to get rid of this padding drama
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Container(
            alignment: Alignment.center,
            margin: filterPanelPadding,
            height: context.t.appBarTheme.toolbarHeight,
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
                Text(
                  context.l10n.station,
                  style: chipTextStyle(theme),
                ),
                Text(
                  context.l10n.tags,
                  style: chipTextStyle(theme),
                ),
                Text(
                  context.l10n.hearingHistory,
                  style: chipTextStyle(theme),
                ),
              ],
              isSelected: RadioCollectionView.values
                  .map((e) => e == radioCollectionView)
                  .toList(),
            ),
          ),
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
          padding: getAdaptiveHorizontalPadding(constraints: constraints),
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
          padding: getAdaptiveHorizontalPadding(constraints: constraints),
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
                di<LibraryModel>().pushNamed(pageId: kSearchPageId);
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

  IconData getIconForTag(String tag) {
    final tagsToIcons = <String, IconData>{
      'metal': TablerIcons.guitar_pick,
      'pop': TablerIcons.diamond,
    };

    return tagsToIcons[tag] ??
        (yaruStyled
            ? YaruIcons.music_note
            : appleStyled
                ? CupertinoIcons.double_music_note
                : Icons.music_note);
  }
}
