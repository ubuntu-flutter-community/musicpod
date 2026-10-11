import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/common_control_panel.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../../podcasts/manager/podcast_load_genres_manager.dart';
import '../manager/search_manager.dart';

class SliverPodcastFilterBar extends StatelessWidget with WatchItMixin {
  const SliverPodcastFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final podcastGenre = watchValue((SearchManager m) => m.podcastGenre);

    return Consumer(
      builder: (context, ref, _) {
        final genresAsync = ref.watch(podcastLoadGenresManagerProvider);

        return genresAsync.when(
          loading: () => const Progress(),
          error: (_, __) => const SizedBox.shrink(),
          data: (result) => CommonControlPanel(
            labels: result.map((e) => Text(e.localize(context.l10n))).toList(),
            isSelected: result.map((e) => e == podcastGenre).toList(),
            onSelected: (i) => di<SearchManager>()
              ..setSearchQuery(null)
              ..setPodcastGenre(result[i])
              ..search(clear: true),
          ),
        );
      },
    );
  }
}
