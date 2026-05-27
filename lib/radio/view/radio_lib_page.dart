import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/sliver_body.dart';
import '../../extensions/build_context_x.dart';
import '../../settings/view/settings_action.dart';
import '../radio_manager.dart';
import 'blocked_heariny_history_list.dart';
import 'favorite_radio_tags_grid.dart';
import 'radio_connect_mixin.dart';
import 'radio_history_list.dart';
import 'radio_lib_page_control_panel.dart';
import 'radio_reconnect_button.dart';
import 'starred_stations_grid.dart';

class RadioLibPage extends StatelessWidget
    with WatchItMixin, RadioConnectMixin {
  const RadioLibPage({super.key});

  @override
  Widget build(BuildContext context) {
    callOnceAfterThisBuild(
      (_) => di<RadioManager>().maybeConnect(clearErrors: false),
    );

    registerRadioConnectHandler(context);

    final radioCollectionView = watchValue(
      (RadioManager m) => m.radioCollectionView,
    );

    final cooldown = watchValue((RadioManager m) => m.cooldown);

    return watchValue((RadioManager m) => m.connectCommand.results).toWidget(
      whileRunning: (lastResult, param) => const Center(child: Progress()),
      onError: (error, lastResult, param) => NoSearchResultPage(
        icon: FilledButton(
          onPressed: () => di<RadioManager>().maybeConnect(clearErrors: true),
          child: Text(
            cooldown == 0
                ? context.l10n.retry
                : context.l10n.retryngInSeconds(cooldown.toString()),
          ),
        ),
        message: Text(error.toString()),
      ),
      onData: (connectedHost, param) => connectedHost == null
          ? const SliverFillRemaining(
              child: SizedBox(width: 100, child: RadioReconnectButton()),
            )
          : SliverBody(
              controlPanel: const RadioLibPageControlPanel(),
              controlPanelSuffix: const SettingsButton.icon(scrollIndex: 3),
              contentBuilder: (context, constraints) =>
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
