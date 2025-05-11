import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/adaptive_container.dart';
import '../../common/view/no_search_result_page.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import 'radio_history_tile.dart';

class RadioHistoryList extends StatelessWidget with WatchItMixin {
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
    final length = watchPropertyValue(
      (PlayerModel m) => m.getRadioHistoryLength(filter: filter),
    );

    final current = watchPropertyValue((PlayerModel m) => m.mpvMetaData);

    if (length == 0) {
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
            itemCount: length,
            itemBuilder: (context, index) {
              final reversedIndex = length - index - 1;
              final e = di<PlayerModel>()
                  .filteredRadioHistory(filter: filter)
                  .elementAt(reversedIndex);
              return simpleList
                  ? RadioHistoryTile.simple(
                      icyTitle: e.key,
                      selected: current?.icyTitle != null &&
                          current?.icyTitle == e.value.icyTitle,
                    )
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: RadioHistoryTile(
                        icyTitle: e.key,
                        selected: current?.icyTitle != null &&
                            current?.icyTitle == e.value.icyTitle,
                      ),
                    );
            },
          );
        },
      ),
    );
  }
}

class SliverRadioHistoryList extends StatelessWidget with WatchItMixin {
  const SliverRadioHistoryList({
    super.key,
    this.filter,
    this.emptyMessage,
    this.padding,
    this.emptyIcon,
    this.allowNavigation = true,
  });

  final String? filter;
  final Widget? emptyMessage;
  final Widget? emptyIcon;
  final EdgeInsetsGeometry? padding;
  final bool allowNavigation;

  @override
  Widget build(BuildContext context) {
    final length = watchPropertyValue(
      (PlayerModel m) => m.getRadioHistoryLength(filter: filter),
    );

    final current = watchPropertyValue((PlayerModel m) => m.mpvMetaData);

    if (length == 0) {
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
          final reversedIndex = length - index - 1;
          final e = di<PlayerModel>()
              .filteredRadioHistory(filter: filter)
              .elementAt(reversedIndex);
          return RadioHistoryTile(
            icyTitle: e.key,
            selected: current?.icyTitle != null &&
                current?.icyTitle == e.value.icyTitle,
            allowNavigation: allowNavigation,
          );
        },
        childCount: length,
      ),
    );
  }
}
