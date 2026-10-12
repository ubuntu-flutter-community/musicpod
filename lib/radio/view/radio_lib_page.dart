import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/default_page_body.dart';
import '../../settings/view/settings_action.dart';
import '../data/radio_collection_view.dart';
import '../manager/radio_collection_view_manager.dart';
import 'blocked_heariny_history_list.dart';
import 'favorite_radio_tags_grid.dart';
import 'radio_connect_mixin.dart';
import 'radio_history_list.dart';
import 'radio_lib_page_control_panel.dart';
import 'starred_stations_grid.dart';

class RadioLibPage extends ConsumerWidget with RadioConnectMixin {
  const RadioLibPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    registerRadioConnectHandler(context, ref);

    final radioCollectionView = ref.watch(radioCollectionViewManagerProvider);

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
