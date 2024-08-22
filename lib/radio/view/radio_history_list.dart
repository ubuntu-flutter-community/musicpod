import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/adaptive_container.dart';
import '../../common/view/no_search_result_page.dart';
import '../../l10n/l10n.dart';
import '../../player/player_mixin.dart';
import '../../player/player_model.dart';
import 'radio_history_tile.dart';

class RadioHistoryList extends StatelessWidget with WatchItMixin, PlayerMixin {
  const RadioHistoryList({
    super.key,
    this.filter,
    this.emptyMessage,
    this.padding,
    this.emptyIcon,
    this.simpleList = false,
  });

  final String? filter;
  final Widget? emptyMessage;
  final Widget? emptyIcon;
  final EdgeInsetsGeometry? padding;
  final bool simpleList;

  @override
  Widget build(BuildContext context) {
    final radioHistory = watchPropertyValue(
      (PlayerModel m) => m.filteredRadioHistory(filter: filter),
    );
    final current = watchPropertyValue((PlayerModel m) => m.mpvMetaData);

    if (radioHistory.isEmpty) {
      return NoSearchResultPage(
        icon: emptyIcon ?? const AnimatedEmoji(AnimatedEmojis.crystalBall),
        message: emptyMessage ?? Text(context.l10n.emptyHearingHistory),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView.builder(
            padding: getAdaptiveHorizontalPadding(constraints: constraints),
            itemCount: radioHistory.length,
            itemBuilder: (context, index) {
              final reversedIndex = radioHistory.length - index - 1;
              final e = radioHistory.elementAt(reversedIndex);
              return RadioHistoryTile(
                simpleTile: simpleList,
                entry: e,
                selected: current?.icyTitle != null &&
                    current?.icyTitle == e.value.icyTitle,
              );
            },
          );
        },
      ),
    );
  }
}

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
          icon: emptyIcon ?? const AnimatedEmoji(AnimatedEmojis.crystalBall),
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
            entry: e,
            selected: current?.icyTitle != null &&
                current?.icyTitle == e.value.icyTitle,
          );
        },
        childCount: radioHistory.length,
      ),
    );
  }
}
