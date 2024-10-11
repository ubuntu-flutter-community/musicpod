import '../../extensions/build_context_x.dart';
import '../../library/library_model.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class PodcastPageTitle extends StatelessWidget with WatchItMixin {
  const PodcastPageTitle({
    super.key,
    required this.feedUrl,
    required this.title,
  });

  final String feedUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((LibraryModel m) => m.podcastUpdatesLength);
    final visible = di<LibraryModel>().podcastUpdateAvailable(feedUrl);
    return Badge(
      backgroundColor: context.theme.colorScheme.primary,
      isLabelVisible: visible,
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(right: visible ? 10 : 0),
        child: Text(title),
      ),
    );
  }
}
