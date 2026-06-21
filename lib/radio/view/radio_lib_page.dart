import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/clean_up_caches.dart';
import '../../common/view/default_page_body.dart';
import '../../settings/view/settings_action.dart';
import '../data/radio_collection_view.dart';
import '../manager/radio_manager.dart';
import 'blocked_heariny_history_list.dart';
import 'favorite_radio_tags_grid.dart';
import 'radio_connect_mixin.dart';
import 'radio_history_list.dart';
import 'radio_lib_page_control_panel.dart';
import 'starred_stations_grid.dart';

class RadioLibPage extends StatelessWidget
    with WatchItMixin, RadioConnectMixin {
  const RadioLibPage({super.key});

  @override
  Widget build(BuildContext context) {
    callOnceAfterThisBuild((_) => cleanUpLocalAudioCaches());

    registerRadioConnectHandler(context);

    final radioCollectionView = watchValue(
      (RadioManager m) => m.radioCollectionView,
    );

    return DefaultPageBody(
      controlPanel: const RadioLibPageControlPanel(),
      controlPanelSuffix: const SettingsButton.icon(scrollIndex: 3),
      sliverContentBuilder: (context, constraints) =>
          switch (radioCollectionView) {
            RadioCollectionView.stations => const StarredStationsGrid(),
            RadioCollectionView.tags => const FavoriteRadioTagsGrid(),
            RadioCollectionView.history => const SliverRadioHistoryList(),
            RadioCollectionView.ignoredIcyTitles =>
              const BlockedHearinyHistoryList(),
          },
    );
  }
}
