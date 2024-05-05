import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';

import '../../../common.dart';
import '../../../get.dart';
import '../../../l10n.dart';
import '../../../player.dart';
import 'radio_history_tile.dart';

class SliverRadioHistoryList extends StatelessWidget
    with WatchItMixin, PlayerMixin {
  const SliverRadioHistoryList({
    super.key,
    this.filter,
    this.emptyMessage,
    this.padding,
    this.emptyIcon,
  });

  final String? filter;
  final Widget? emptyMessage;
  final Widget? emptyIcon;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final radioHistory = watchPropertyValue(
      (PlayerModel m) => m.filteredRadioHistory(filter: filter),
    );
    final current = watchPropertyValue((PlayerModel m) => m.mpvMetaData);

    if (radioHistory.isEmpty) {
      return SliverToBoxAdapter(
        child: NoSearchResultPage(
          icons: emptyIcon ?? const AnimatedEmoji(AnimatedEmojis.crystalBall),
          message: emptyMessage ?? Text(context.l10n.emptyHearingHistory),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final reversedIndex = radioHistory.length - index - 1;
          final e = radioHistory.elementAt(reversedIndex);
          return RadioHistoryTile(
            e: e,
            selected: current?.icyTitle != null &&
                current?.icyTitle == e.value.icyTitle,
          );
        },
        childCount: radioHistory.length,
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
