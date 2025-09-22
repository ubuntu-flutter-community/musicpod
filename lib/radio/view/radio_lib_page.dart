import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/sliver_body.dart';
import '../../settings/view/settings_action.dart';
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

    return SliverBody(
      controlPanel: const RadioLibPageControlPanel(),
      controlPanelSuffix: const SettingsButton.icon(scrollIndex: 3),
      contentBuilder: (context, constraints) => switch (radioCollectionView) {
        RadioCollectionView.stations => const StarredStationsGrid(),
        RadioCollectionView.tags => const FavoriteRadioTagsGrid(),
        RadioCollectionView.history => const SliverRadioHistoryList(),
      },
    );
  }
}
