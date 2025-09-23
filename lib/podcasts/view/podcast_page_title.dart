import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/string_x.dart';
import '../../library/library_model.dart';

class PodcastPageTitle extends StatelessWidget with WatchItMixin {
  const PodcastPageTitle({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((LibraryModel m) => m.podcastUpdatesLength);
    final title = di<LibraryModel>().getSubscribedPodcastName(feedUrl) ?? '';
    final visible = di<LibraryModel>().podcastUpdateAvailable(feedUrl);
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
      Text(di<LibraryModel>().getSubscribedPocastArtist(feedUrl) ?? '');
}
