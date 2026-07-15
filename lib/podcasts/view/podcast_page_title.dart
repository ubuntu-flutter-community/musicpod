import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/string_x.dart';
import '../manager/podcast_short_info_manager.dart';
import '../manager/podcast_updates_manager.dart';

class PodcastPageTitle extends StatelessWidget with WatchItMixin {
  const PodcastPageTitle({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final title = watchValue(
      (PodcastShortInfoManager m) => m.command,
      param1: feedUrl,
    )?.name;
    final visible = watchValue(
      (PodcastUpdatesManager m) => m.command,
    ).containsKey(feedUrl);
    return Badge(
      backgroundColor: context.theme.colorScheme.primary,
      isLabelVisible: visible,
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(right: visible ? 10 : 0),
        child: Text(title?.unEscapeHtml ?? title ?? context.l10n.podcast),
      ),
    );
  }
}

class PodcastPageSubTitle extends StatelessWidget with WatchItMixin {
  const PodcastPageSubTitle({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) => Text(
    watchValue(
          (PodcastShortInfoManager m) => m.command,
          param1: feedUrl,
        )?.artist ??
        '',
  );
}
