import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../player/manager/blocked_icy_titles_manager.dart';

class BlockedHearinyHistoryList extends ConsumerWidget {
  const BlockedHearinyHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedIcyTitles = ref.watch(blockedIcyTitlesManagerProvider);
    return SliverList.builder(
      itemCount: blockedIcyTitles.length,
      itemBuilder: (context, index) {
        final title = blockedIcyTitles.elementAt(index);
        return ListTile(
          key: ValueKey(title),
          title: Text(title),
          leading: IconButton(
            tooltip: context.l10n.removeFromIgnoredHearyHistoryTitles,
            onPressed: () => ref
                .read(blockedIcyTitlesManagerProvider.notifier)
                .remove(title),
            icon: Icon(Iconz.remove),
          ),
        );
      },
    );
  }
}
