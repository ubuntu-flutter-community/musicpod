import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/view/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/icons.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/round_image_container.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../custom_content/custom_content_model.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../../settings/view/settings_action.dart';
import '../radio_model.dart';
import 'open_radio_discover_page_button.dart';
import 'radio_history_list.dart';
import 'station_card.dart';

class RadioLibPage extends StatelessWidget with WatchItMixin {
  const RadioLibPage({super.key});

  @override
  Widget build(BuildContext context) {
    final radioCollectionView =
        watchPropertyValue((RadioModel m) => m.radioCollectionView);
    final radioModel = di<RadioModel>();
    final processing =
        watchPropertyValue((CustomContentModel m) => m.processing);

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          margin: filterPanelPadding,
          height: context.theme.appBarTheme.toolbarHeight,
          child: Row(
            spacing: kSmallestSpace,
            children: [
              const SizedBox(width: kSmallestSpace + 2 * kLargestSpace),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: YaruChoiceChipBar(
                        showCheckMarks: false,
                        goNextIcon: Icon(Iconz.goNext),
                        goPreviousIcon: Icon(Iconz.goBack),
                        selectedFirst: false,
                        clearOnSelect: false,
                        onSelected: (index) =>
                            radioModel.setRadioCollectionView(
                          RadioCollectionView.values[index],
                        ),
                        style: YaruChoiceChipBarStyle.wrap,
                        labels: [
                          Text(
                            context.l10n.station,
                          ),
                          Text(
                            context.l10n.tags,
                          ),
                          Text(
                            context.l10n.hearingHistory,
                          ),
                        ],
                        isSelected: RadioCollectionView.values
                            .map((e) => e == radioCollectionView)
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
              const SettingsButton.icon(scrollIndex: 3),
              const SizedBox(width: kSmallestSpace),
            ],
          ),
        ),
        Expanded(
          child: processing
              ? const Center(
                  child: Progress(),
                )
              : switch (radioCollectionView) {
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

    if (length == 0) {
      return NoSearchResultPage(
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: getAdaptiveHorizontalPadding(constraints: constraints),
          gridDelegate: audioCardGridDelegate,
          itemCount: length,
          itemBuilder: (context, index) {
            final uuid = stations.elementAt(index);
            return StationCard(uuid: uuid);
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
              height: kLargestSpace,
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
          gridDelegate: kDiskGridDelegate,
          itemCount: favTagsLength,
          itemBuilder: (context, index) {
            final text = favTags.elementAt(index);
            final color = getAlphabetColor(text).scale(saturation: -0.2);
            final textColor = contrastColor(color);
            final tag = favTags.elementAt(index);
            return YaruSelectableContainer(
              selected: false,
              onTap: () {
                di<RoutingManager>().push(pageId: PageIDs.searchPage);
                di<SearchModel>()
                  ..setSearchType(SearchType.radioTag)
                  ..setTag(Tag(name: tag.toLowerCase(), stationCount: 1))
                  ..setAudioType(AudioType.radio)
                  ..search();
              },
              borderRadius: BorderRadius.circular(300),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: RoundImageContainer(
                      images: [],
                      fallBackText: text,
                      backgroundColor: color,
                    ),
                  ),
                  RoundImageContainerVignette(
                    text: text,
                    backgroundColor: Colors.transparent,
                    textColor: textColor,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
