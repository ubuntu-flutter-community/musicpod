import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/no_search_result_page.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../player/manager/mpv_metadata_history_manager.dart';
import '../../player/manager/mpv_metadata_manager.dart';
import 'radio_history_tile.dart';

class RadioHistoryList extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(mpvMetadataHistoryManagerProvider);
    final filtered = ref
        .read(mpvMetadataHistoryManagerProvider.notifier)
        .filteredHistory(filter: filter)
        .toList();
    final length = filtered.length;
    final current = ref.watch(mpvMetadataManagerProvider);

    if (length == 0) {
      return NoSearchResultPage(
        message: emptyMessage ?? Text(context.l10n.emptyHearingHistory),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ListView.builder(
        padding: kGridPadding,
        itemCount: length,
        itemBuilder: (context, index) {
          final reversedIndex = length - index - 1;
          final e = filtered[reversedIndex];
          return simpleList
              ? RadioHistoryTile.simple(
                  key: ValueKey(
                    e.key,
                  ), // Force rebuild when remote image changes
                  icyTitle: e.key,
                  selected:
                      current?.icyTitle != null &&
                      current?.icyTitle == e.value.icyTitle,
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: RadioHistoryTile(
                    key: ValueKey(
                      e.key,
                    ), // Force rebuild when remote image changes
                    icyTitle: e.key,
                    selected:
                        current?.icyTitle != null &&
                        current?.icyTitle == e.value.icyTitle,
                  ),
                );
        },
      ),
    );
  }
}

class SliverRadioHistoryList extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(mpvMetadataHistoryManagerProvider);
    final filtered = ref
        .read(mpvMetadataHistoryManagerProvider.notifier)
        .filteredHistory(filter: filter)
        .toList();
    final length = filtered.length;
    final current = ref.watch(mpvMetadataManagerProvider);

    if (length == 0) {
      return SliverToBoxAdapter(
        child: NoSearchResultPage(
          message: emptyMessage ?? Text(context.l10n.emptyHearingHistory),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final reversedIndex = length - index - 1;
        final e = filtered[reversedIndex];
        return RadioHistoryTile(
          key: ValueKey(e.key),
          icyTitle: e.key,
          selected:
              current?.icyTitle != null &&
              current?.icyTitle == e.value.icyTitle,
          allowNavigation: allowNavigation,
        );
      }, childCount: length),
    );
  }
}
