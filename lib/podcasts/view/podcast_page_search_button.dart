import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '../../common/view/icons.dart';
import '../podcast_model.dart';

class PodcastPageSearchButton extends StatelessWidget with WatchItMixin {
  const PodcastPageSearchButton({
    super.key,
    required this.feedUrl,
  });

  final String feedUrl;

  @override
  Widget build(BuildContext context) => IconButton(
        isSelected:
            watchPropertyValue((PodcastModel m) => m.getShowSearch(feedUrl)),
        onPressed: () => di<PodcastModel>().toggleShowSearch(feedUrl: feedUrl),
        icon: Icon(Iconz.search),
      );
}
