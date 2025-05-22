import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../podcast_model.dart';

class PodcastPageSearchButton extends StatelessWidget with WatchItMixin {
  const PodcastPageSearchButton({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final search = context.l10n.search;
    return IconButton(
      tooltip: search,
      isSelected: watchPropertyValue(
        (PodcastModel m) => m.getShowSearch(feedUrl),
      ),
      onPressed: feedUrl.isEmpty
          ? null
          : () => di<PodcastModel>().toggleShowSearch(feedUrl: feedUrl),
      icon: Icon(Iconz.search, semanticLabel: search),
    );
  }
}
