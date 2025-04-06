import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../custom_content/custom_content_model.dart';
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
    final l10n = context.l10n;
    final radioCollectionView =
        watchPropertyValue((RadioModel m) => m.radioCollectionView);
    final radioModel = di<RadioModel>();
    final importingExporting =
        watchPropertyValue((CustomContentModel m) => m.importingExporting);

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          margin: filterPanelPadding,
          height: context.theme.appBarTheme.toolbarHeight,
          child: Row(
            spacing: kSmallestSpace,
            children: [
              const SizedBox(width: 2 * kLargestSpace),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: YaruChoiceChipBar(
                      goNextIcon: Icon(Iconz.goNext),
                      goPreviousIcon: Icon(Iconz.goBack),
                      selectedFirst: false,
                      clearOnSelect: false,
                      onSelected: (index) => radioModel.setRadioCollectionView(
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
              IconButton(
                tooltip: l10n.exportStarredStationsToOpmlFile,
                icon: Icon(
                  Iconz.download,
                  semanticLabel: l10n.exportStarredStationsToOpmlFile,
                ),
                onPressed: importingExporting
                    ? null
                    : () => di<CustomContentModel>()
                        .exportStarredStationsToOpmlFile(),
              ),
              IconButton(
                tooltip: l10n.importStarredStationsFromOpmlFile,
                icon: Icon(
                  Iconz.upload,
                  semanticLabel: l10n.importStarredStationsFromOpmlFile,
                ),
                onPressed: importingExporting
                    ? null
                    : () => di<CustomContentModel>()
                        .importStarredStationsFromOpmlFile(),
              ),
              IconButton(
                icon: Icon(
                  Iconz.remove,
                  semanticLabel: l10n.removeAllStarredStations,
                ),
                tooltip: context.l10n.removeAllStarredStations,
                onPressed: importingExporting
                    ? null
                    : () => showDialog(
                          context: context,
                          builder: (context) {
                            return ConfirmationDialog(
                              showCloseIcon: false,
                              title: Text(l10n.removeAllStarredStationsConfirm),
                              content: SizedBox(
                                width: 350,
                                child: Text(
                                  l10n.removeAllStarredStationsDescription,
                                ),
                              ),
                              onConfirm: () =>
                                  di<LibraryModel>().unStarAllStations(),
                            );
                          },
                        ),
              ),
              const SizedBox(width: kMediumSpace),
            ],
          ),
        ),
        Expanded(
          child: importingExporting
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
    final playerModel = di<PlayerModel>();

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
                di<LibraryModel>().push(pageId: PageIDs.searchPage);
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
        (AppConfig.yaruStyled
            ? YaruIcons.music_note
            : AppConfig.appleStyled
                ? CupertinoIcons.double_music_note
                : Icons.music_note);
  }
}
