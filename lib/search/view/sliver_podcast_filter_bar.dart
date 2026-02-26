import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/podcast_genre.dart';
import '../../common/view/common_control_panel.dart';
import '../../common/view/progress.dart';
import '../../l10n/l10n.dart';
import '../search_model.dart';

class SliverPodcastFilterBar extends StatelessWidget with WatchItMixin {
  const SliverPodcastFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    callOnceAfterThisBuild(
      (context) => di<SearchModel>().loadPodcastGenresCommand.run(),
    );

    final searchModel = di<SearchModel>();

    final podcastGenre = watchPropertyValue((SearchModel m) => m.podcastGenre);

    final setPodcastGenre = searchModel.setPodcastGenre;

    return watchValue(
      (SearchModel m) => m.loadPodcastGenresCommand.results,
    ).toWidget(
      whileRunning: (lastResult, param) => const Progress(),
      onError: (_, lastResult, _) => lastResult != null
          ? CommonControlPanel(
              labels: lastResult
                  .map((e) => Text(e.localize(context.l10n)))
                  .toList(),
              isSelected: lastResult.map((e) => e == podcastGenre).toList(),
              onSelected: (i) {
                searchModel.setSearchQuery(null);
                setPodcastGenre(PodcastGenre.values.elementAt(i));
                searchModel.search();
              },
            )
          : const SizedBox.shrink(),
      onData: (result, param) => CommonControlPanel(
        labels: result.map((e) => Text(e.localize(context.l10n))).toList(),
        isSelected: result.map((e) => e == podcastGenre).toList(),
        onSelected: (i) {
          searchModel.setSearchQuery(null);
          setPodcastGenre(PodcastGenre.values.elementAt(i));
          searchModel.search();
        },
      ),
    );
  }
}
