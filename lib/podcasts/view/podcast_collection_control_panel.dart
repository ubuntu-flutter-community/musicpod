import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/connectivity_model.dart';
import '../../common/view/icons.dart';
import '../../common/view/offline_page.dart';
import '../../l10n/l10n.dart';
import '../podcast_model.dart';

class PodcastCollectionControlPanel extends StatelessWidget with WatchItMixin {
  const PodcastCollectionControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final model = di<PodcastModel>();

    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);
    if (!isOnline) return const OfflineBody();

    final loading =
        watchPropertyValue((PodcastModel m) => m.checkingForUpdates);
    final updatesOnly = watchPropertyValue((PodcastModel m) => m.updatesOnly);
    final downloadsOnly =
        watchPropertyValue((PodcastModel m) => m.downloadsOnly);

    return YaruChoiceChipBar(
      goNextIcon: Icon(Iconz.goNext),
      goPreviousIcon: Icon(Iconz.goBack),
      style: YaruChoiceChipBarStyle.wrap,
      clearOnSelect: false,
      selectedFirst: false,
      labels: [
        Text(
          context.l10n.newEpisodes,
        ),
        Text(
          context.l10n.downloadsOnly,
        ),
      ],
      isSelected: [
        updatesOnly,
        downloadsOnly,
      ],
      onSelected: loading
          ? null
          : (index) {
              if (index == 0) {
                if (updatesOnly) {
                  model.setUpdatesOnly(false);
                } else {
                  model.update(updateMessage: context.l10n.newEpisodeAvailable);
                  model.setUpdatesOnly(true);
                  model.setDownloadsOnly(false);
                }
              } else {
                if (downloadsOnly) {
                  model.setDownloadsOnly(false);
                } else {
                  model.setDownloadsOnly(true);
                  model.setUpdatesOnly(false);
                }
              }
            },
    );
  }
}
