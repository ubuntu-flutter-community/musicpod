import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/adaptive_container.dart';
import '../../common/view/progress.dart';
import '../../custom_content/custom_content_model.dart';
import '../radio_model.dart';
import 'favorite_radio_tags_grid.dart';
import 'radio_history_list.dart';
import 'radio_lib_page_control_panel.dart';
import 'starred_stations_grid.dart';

class RadioLibPage extends StatelessWidget with WatchItMixin {
  const RadioLibPage({super.key});

  @override
  Widget build(BuildContext context) {
    final radioCollectionView = watchPropertyValue(
      (RadioModel m) => m.radioCollectionView,
    );
    final processing = watchPropertyValue(
      (CustomContentModel m) => m.processing,
    );

    return Column(
      children: [
        const RadioLibPageControlPanel(),
        Expanded(
          child: processing
              ? const Center(child: Progress())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: getAdaptiveHorizontalPadding(
                            constraints: constraints,
                          ),
                          sliver: switch (radioCollectionView) {
                            RadioCollectionView.stations =>
                              const StarredStationsGrid(),
                            RadioCollectionView.tags =>
                              const FavoriteRadioTagsGrid(),
                            RadioCollectionView.history =>
                              const SliverRadioHistoryList(),
                          },
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
