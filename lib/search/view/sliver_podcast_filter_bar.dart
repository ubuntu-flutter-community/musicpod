import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/common_control_panel.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../search_manager.dart';

class SliverPodcastFilterBar extends StatelessWidget with WatchItMixin {
  const SliverPodcastFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    callOnceAfterThisBuild(
      (context) => di<SearchManager>().loadPodcastGenresCommand.run(),
    );

    final podcastGenre = watchValue((SearchManager m) => m.podcastGenre);

    return watchValue(
      (SearchManager m) => m.loadPodcastGenresCommand.results,
    ).toWidget(
      whileRunning: (lastResult, param) => const Progress(),
      onError: (_, lastResult, _) => const SizedBox.shrink(),
      onData: (result, param) => CommonControlPanel(
        labels: result.map((e) => Text(e.localize(context.l10n))).toList(),
        isSelected: result.map((e) => e == podcastGenre).toList(),
        onSelected: (i) => di<SearchManager>()
          ..setSearchQuery(null)
          ..setPodcastGenre(result[i])
          ..search(clear: true),
      ),
    );
  }
}
