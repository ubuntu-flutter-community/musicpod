import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/string_x.dart';
import '../manager/podcast_short_info_manager.dart';
import '../manager/podcast_updated_feeds_manager.dart';

class PodcastPageTitle extends ConsumerWidget {
  const PodcastPageTitle({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible =
        ref.watch(podcastUpdatedFeedsManagerProvider).value?.contains(feedUrl) ??
        false;
    final title =
        ref.watch(podcastShortInfoManagerProvider(feedUrl)).value?.name;

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

class PodcastPageSubTitle extends ConsumerWidget {
  const PodcastPageSubTitle({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Text(
    ref.watch(podcastShortInfoManagerProvider(feedUrl)).value?.artist ?? '',
  );
}
