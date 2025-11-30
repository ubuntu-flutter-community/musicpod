import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/podcast_genre.dart';
import '../../common/view/common_control_panel.dart';
import '../../l10n/l10n.dart';
import '../../settings/settings_model.dart';
import '../search_model.dart';

class SliverPodcastFilterBar extends StatelessWidget with WatchItMixin {
  const SliverPodcastFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final searchModel = di<SearchModel>();

    final podcastGenre = watchPropertyValue((SearchModel m) => m.podcastGenre);
    final usePodcastIndex = watchPropertyValue(
      (SettingsModel m) => m.usePodcastIndex,
    );
    final genres = watchPropertyValue(
      (SearchModel m) => m.getPodcastGenres(usePodcastIndex),
    );

    final setPodcastGenre = searchModel.setPodcastGenre;

    return CommonControlPanel(
      labels: genres.map((e) => Text(e.localize(context.l10n))).toList(),
      isSelected: genres.map((e) => e == podcastGenre).toList(),
      onSelected: (i) {
        searchModel.setSearchQuery(null);
        setPodcastGenre(PodcastGenre.values.elementAt(i));
        searchModel.search();
      },
    );
  }
}
