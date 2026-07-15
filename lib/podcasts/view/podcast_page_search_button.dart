import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../manager/episodes_manager.dart';

class PodcastPageSearchButton extends StatelessWidget with WatchItMixin {
  const PodcastPageSearchButton({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final search = context.l10n.search;
    return IconButton(
      tooltip: search,
      isSelected: watchValue(
        (EpisodesManager m) => m.showSearch,
        param1: feedUrl,
      ),
      onPressed: feedUrl.isEmpty
          ? null
          : () => di<EpisodesManager>(param1: feedUrl).toggleShowSearch(),
      icon: Icon(Iconz.search, semanticLabel: search),
    );
  }
}
