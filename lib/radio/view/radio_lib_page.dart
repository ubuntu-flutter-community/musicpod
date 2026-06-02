import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/default_page_body.dart';
import '../../common/view/progress.dart';
import '../../extensions/command_x.dart';
import '../../settings/view/settings_action.dart';
import '../radio_manager.dart';
import '../radio_service.dart';
import 'blocked_heariny_history_list.dart';
import 'favorite_radio_tags_grid.dart';
import 'radio_connect_mixin.dart';
import '../../common/view/error_retry_body.dart';
import 'radio_history_list.dart';
import 'radio_lib_page_control_panel.dart';
import 'starred_stations_grid.dart';

class RadioLibPage extends StatelessWidget
    with WatchItMixin, RadioConnectMixin {
  const RadioLibPage({super.key});

  @override
  Widget build(BuildContext context) {
    callAfterEveryBuild(
      (_, _) => di<RadioManager>().connectCommand.runRestricted(
        immediatelyClearErrors: false,
      ),
    );

    registerRadioConnectHandler(context);

    final radioCollectionView = watchValue(
      (RadioManager m) => m.radioCollectionView,
    );

    return watchValue((RadioManager m) => m.connectCommand.results).toWidget(
      whileRunning: (lastResult, param) => const Center(child: Progress()),
      onError: (error, lastResult, param) => ErrorRetryBody(
        cooldown: di<RadioManager>().connectCommand.cooldown,
        error: error,
        onRetry: () => di<RadioManager>().connectCommand.runRestricted(
          immediatelyClearErrors: true,
        ),
      ),
      onData: (connectedHost, param) => connectedHost == null
          ? ErrorRetryBody(
              cooldown: di<RadioManager>().connectCommand.cooldown,
              error: RadioBrowserApiNotConnectedException(),
              onRetry: () => di<RadioManager>().connectCommand.runRestricted(
                immediatelyClearErrors: true,
              ),
            )
          : DefaultPageBody(
              controlPanel: const RadioLibPageControlPanel(),
              controlPanelSuffix: const SettingsButton.icon(scrollIndex: 3),
              sliverContentBuilder: (context, constraints) =>
                  switch (radioCollectionView) {
                    RadioCollectionView.stations => const StarredStationsGrid(),
                    RadioCollectionView.tags => const FavoriteRadioTagsGrid(),
                    RadioCollectionView.history =>
                      const SliverRadioHistoryList(),
                    RadioCollectionView.ignoredIcyTitles =>
                      const BlockedHearinyHistoryList(),
                  },
            ),
    );
  }
}
