import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../podcast_manager.dart';

class PodcastPageSearchButton extends StatelessWidget with WatchItMixin {
  const PodcastPageSearchButton({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final search = context.l10n.search;
    return IconButton(
      tooltip: search,
      isSelected: watchValue((PodcastManager m) => m.showSearch),
      onPressed: feedUrl.isEmpty
          ? null
          : () => di<PodcastManager>().toggleShowSearch(),
      icon: Icon(Iconz.search, semanticLabel: search),
    );
  }
}
