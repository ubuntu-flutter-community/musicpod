import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../common.dart';
import '../../l10n.dart';
import '../../library.dart';
import '../../player.dart';
import '../../radio.dart';
import '../common/icy_image.dart';
import 'radio_search.dart';

class RadioHistoryList extends ConsumerWidget {
  const RadioHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radioHistory =
        ref.watch(libraryModelProvider.select((l) => l.radioHistory));
    final current = ref.watch(playerModelProvider.select((p) => p.mpvMetaData));

    if (radioHistory.isEmpty) {
      return NoSearchResultPage(
        icons: const AnimatedEmoji(AnimatedEmojis.crystalBall),
        message: Text(context.l10n.emptyHearingHistory),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ListView.builder(
        physics: const PositionRetainedScrollPhysics(),
        reverse: true,
        shrinkWrap: true,
        padding: const EdgeInsets.only(
          left: 10,
          bottom: kYaruPagePadding,
        ),
        itemCount: radioHistory.length,
        itemBuilder: (context, index) {
          final e = radioHistory.entries.elementAt(index);
          return ListTile(
            selected: current?.icyTitle != null &&
                current?.icyTitle == e.value.icyTitle,
            leading: IcyImage(mpvMetaData: e.value),
            title: TapAbleText(
              overflow: TextOverflow.visible,
              maxLines: 10,
              text: e.value.icyTitle,
              onTap: () => onTitleTap(
                text: e.value.icyTitle,
                context: context,
                ref: ref,
              ),
            ),
            subtitle: TapAbleText(
              text: e.value.icyName,
              onTap: () {
                ref
                    .read(radioModelProvider)
                    .getStations(
                      radioSearch: RadioSearch.name,
                      query: e.value.icyName,
                    )
                    .then((stations) {
                  if (stations != null && stations.isNotEmpty) {
                    onArtistTap(
                      audio: stations.first,
                      artist: e.value.icyTitle,
                      context: context,
                      ref: ref,
                    );
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }
}

class PositionRetainedScrollPhysics extends ScrollPhysics {
  final bool shouldRetain;
  const PositionRetainedScrollPhysics({super.parent, this.shouldRetain = true});

  @override
  PositionRetainedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PositionRetainedScrollPhysics(
      parent: buildParent(ancestor),
      shouldRetain: shouldRetain,
    );
  }

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    final position = super.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );

    final diff = newPosition.maxScrollExtent - oldPosition.maxScrollExtent;

    if (oldPosition.pixels > oldPosition.minScrollExtent &&
        diff > 0 &&
        shouldRetain) {
      return position + diff;
    } else {
      return position;
    }
  }
}
