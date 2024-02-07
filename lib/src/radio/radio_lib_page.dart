import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../globals.dart';
import '../../l10n.dart';
import '../../library.dart';
import '../../player.dart';
import '../../radio.dart';
import '../../theme.dart';
import 'radio_search.dart';
import 'radio_search_page.dart';
import 'station_card.dart';

class RadioLibPage extends StatelessWidget {
  const RadioLibPage({
    super.key,
    required this.isOnline,
  });

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    if (!isOnline) {
      return const OfflinePage();
    }

    final theme = context.t;

    return Consumer(
      builder: (context, ref, _) {
        final showTags =
            ref.watch(radioModelProvider.select((p) => p.showTags));
        final radioModel = ref.read(radioModelProvider);
        return Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 25,
                ),
                YaruChoiceChipBar(
                  chipBackgroundColor: chipColor(theme),
                  selectedChipBackgroundColor: chipSelectionColor(theme, false),
                  borderColor: chipBorder(theme, false),
                  selectedFirst: false,
                  clearOnSelect: false,
                  onSelected: (index) =>
                      radioModel.setShowTags(index == 0 ? false : true),
                  yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
                  labels: [
                    Text(context.l10n.station),
                    Text(context.l10n.tags),
                  ],
                  isSelected: [!showTags, showTags],
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            if (showTags)
              const Expanded(child: TagGrid())
            else
              const Expanded(
                child: StationGrid(),
              ),
          ],
        );
      },
    );
  }
}

class StationGrid extends ConsumerWidget {
  const StationGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stations =
        ref.watch(libraryModelProvider.select((p) => p.starredStations));
    final length =
        ref.watch(libraryModelProvider.select((p) => p.starredStationsLength));
    final libraryModel = ref.read(libraryModelProvider);
    final playerModel = ref.read(playerModelProvider);

    if (length == 0) {
      return NoSearchResultPage(
        message: Text(context.l10n.noStarredStations),
        icons: const AnimatedEmoji(AnimatedEmojis.glowingStar),
      );
    }

    return GridView.builder(
      padding: gridPadding,
      gridDelegate: imageGridDelegate,
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

class TagGrid extends ConsumerWidget {
  const TagGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favTagsLength =
        ref.watch(libraryModelProvider.select((p) => p.favTags.length));
    final favTags = ref.watch(libraryModelProvider.select((p) => p.favTags));

    if (favTagsLength == 0) {
      return NoSearchResultPage(
        message: Text(context.l10n.noStarredTags),
        icons: const AnimatedEmoji(AnimatedEmojis.glowingStar),
      );
    }

    return GridView.builder(
      padding: gridPadding,
      gridDelegate: imageGridDelegate,
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
