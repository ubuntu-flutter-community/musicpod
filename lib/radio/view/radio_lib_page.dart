import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/progress.dart';
import '../../common/view/sliver_body.dart';
import '../../common/view/snackbars.dart';
import '../../l10n/l10n.dart';
import '../../settings/view/settings_action.dart';
import '../radio_model.dart';
import 'favorite_radio_tags_grid.dart';
import 'radio_history_list.dart';
import 'radio_lib_page_control_panel.dart';
import 'radio_reconnect_button.dart';
import 'starred_stations_grid.dart';

class RadioLibPage extends StatelessWidget with WatchItMixin {
  const RadioLibPage({super.key});

  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (RadioModel m) => m.connectCommand,
      handler: (context, connectedHost, cancel) {
        showSnackBar(
          context: context,
          duration: const Duration(seconds: 3),
          content: Text(
            connectedHost != null
                ? '${context.l10n.connectedTo}: $connectedHost'
                : context.l10n.noRadioServerFound,
          ),
        );
      },
    );

    final radioCollectionView = watchPropertyValue(
      (RadioModel m) => m.radioCollectionView,
    );

    return watchValue((RadioModel m) => m.connectCommand.results).toWidget(
      whileRunning: (lastResult, param) => const Center(child: Progress()),
      onError: (error, lastResult, param) =>
          const Center(child: RadioReconnectButton()),
      onData: (connectedHost, param) => connectedHost == null
          ? const Center(child: RadioReconnectButton())
          : SliverBody(
              controlPanel: const RadioLibPageControlPanel(),
              controlPanelSuffix: const SettingsButton.icon(scrollIndex: 3),
              contentBuilder: (context, constraints) =>
                  switch (radioCollectionView) {
                    RadioCollectionView.stations => const StarredStationsGrid(),
                    RadioCollectionView.tags => const FavoriteRadioTagsGrid(),
                    RadioCollectionView.history =>
                      const SliverRadioHistoryList(),
                  },
            ),
    );
  }
}
