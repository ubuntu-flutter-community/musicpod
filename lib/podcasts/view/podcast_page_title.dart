import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/string_x.dart';
import '../podcast_manager.dart';

class PodcastPageTitle extends StatelessWidget with WatchItMixin {
  const PodcastPageTitle({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((PodcastManager m) => m.podcastUpdatesLength);
    final title = di<PodcastManager>().getSubscribedPodcastName(feedUrl) ?? '';
    final visible = di<PodcastManager>().podcastUpdateAvailable(feedUrl);
    return Badge(
      backgroundColor: context.theme.colorScheme.primary,
      isLabelVisible: visible,
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(right: visible ? 10 : 0),
        child: Text(title.unEscapeHtml ?? title),
      ),
    );
  }
}

class PodcastPageSubTitle extends StatelessWidget {
  const PodcastPageSubTitle({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) =>
      Text(di<PodcastManager>().getSubscribedPodcastArtist(feedUrl) ?? '');
}
