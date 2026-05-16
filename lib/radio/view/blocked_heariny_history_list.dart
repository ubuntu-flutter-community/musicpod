import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../../player/mpv_metadata_manager.dart';

class BlockedHearinyHistoryList extends StatelessWidget with WatchItMixin {
  const BlockedHearinyHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final blockedIcyTitles = watchValue(
      (MpvMetadataManager m) => m.editBlockedIcyTitleCommand,
    );
    return SliverList.builder(
      itemCount: blockedIcyTitles.length,
      itemBuilder: (context, index) {
        final title = blockedIcyTitles.elementAt(index);
        return ListTile(
          key: ValueKey(title),
          title: Text(title),
          leading: IconButton(
            tooltip: context.l10n.removeFromIgnoredHearyHistoryTitles,
            onPressed: () => di<MpvMetadataManager>().editBlockedIcyTitleCommand
                .run((title: title, addOrRemove: EditIcyTitleInHistory.remove)),
            icon: Icon(Iconz.remove),
          ),
        );
      },
    );
  }
}
